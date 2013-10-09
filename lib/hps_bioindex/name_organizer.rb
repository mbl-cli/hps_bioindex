module HpsBioindex
  class NameOrganizer
    def organize
      clean_names_data
      Item.transaction do
        import_names
      end
      tag_names
    end

    def tag_names
      HpsBioindex.logger.info("Creating tagged version of files")
      bitstreams = Bitstream.where(tagged: false)
      HpsBioindex.logger.info("Tagging %s texts" % bitstreams.size)
      bitstreams.each_with_index do |b, i|
        HpsBioindex.logger.info("Tagging %s bitstream" %
                                i) if i > 0 && i % 20 == 0
        process_tagged_info(b)
      end
    end


    private

    def clean_names_data
      HpsBioindex.logger.info("Cleaning up old data")
      %w(name_strings resolved_name_strings
         canonical_forms outlinks bitstreams_name_strings).each do |t|
        Item.connection.execute("truncate table %s" % t)
      end
    end

    def process_tagged_info(bitstream)
      processed_names = {}
      tag_offsets = []
      names = bitstream.names_info
      names.each do |name|
        process_tag_name(name, processed_names, tag_offsets)
      end
      tag_offsets.each do |offsets|
        name_id = offsets.pop
        offsets << [processed_names[name_id]['url'],
                   processed_names[name_id]['type']]
      end
      file = open(bitstream.path, 'r:utf-8')
      tagged_file = open(bitstream.path + '.tagged', 'w:utf-8')
      if bitstream.path =~ /xhtml$/
        tt = TagAlong::TaggedText.new(File.read(bitstream.path))
        tag_offsets = tt.adjust_offsets(tag_offsets)
      end
      begin
        ta = TagAlong.new(file.read, tag_offsets)
        tagged_file.write(ta.tag("<a href=\"%s\" class=\"%s\">", "</a>"))
      rescue
        require 'ruby-debug'; debugger
        puts ''
      end
      file.close
      tagged_file.close
    end

    def process_tag_name(name, processed_names, tag_offsets)
      tag_offsets << [name['pos_start'], name['pos_end'], name['id']]
      unless processed_names[name['id']] && processed_names[name['id']]['url']
        process_name(name, processed_names)
      end
    end

    def process_name(name, processed_names)
      if processed_names[name['id']]
        n = processed_names[name['id']]
        n['url'] = get_url(name) if !n['url']
      else
        processed_names[name['id']] = {
          'url' => get_url(name),
          'type' => get_tag_type(name)
        }
      end
    end

    def get_url(name)
      name['url'] ? name['url'] : "http://google.com?search=%s#q=%s" %
        [URI.escape(name['name']), URI.escape(name['name'])]
    end

    def get_tag_type(name)
      return "unresolved" unless name['resolved_name_string_id']
      return "doubtful" unless (name['expanded_abbr'] != 1 &&
                                name['in_curated_sources'] &&
                                name['data_sources_num'].to_i > 3)
      'resolved'
    end

    def import_names
      HpsBioindex.logger.info("Importing names from json into database")
      Bitstream.all.each_with_index do |b, i|
        HpsBioindex.logger.info("Processing bitstream %s" %
                               i) if i % 50 == 0 && i > 0

        json_file = b.path + '.json'
        data = JSON.parse(open(json_file, 'r:utf-8').read,
                          symbolize_names: true)
        data[:names].map do |n|
          add_name_strings(n)
        end
        unless data[:names].empty?
          resolve_names(data)
          add_bitstream_names(b, data[:names])
        end
      end
    end

    def add_bitstream_names(bitstream, names)
      names.each do |n|
        name = n[:scientificName]
        verbatim_name = n[:verbatim]
        pos_start = n[:offsetStart]
        pos_end = n[:offsetEnd]
        name_string_id = NameString.where(name: name).first.id
        BitstreamsNameString.create(name_string_id: name_string_id,
                                   bitstream_id: bitstream.id,
                                   verbatim_name: verbatim_name,
                                   pos_start: pos_start,
                                   pos_end: pos_end)
      end
    end

    def resolve_names(data)
      resolved, unresolved = data[:resolved_names].partition do |n|
        n[:results] && n[:results].first
      end
      update_resolved(resolved)
    end

    def update_resolved(resolved)
      return if resolved.empty?
      names = resolved.map do |n|
        Item.connection.quote(n[:supplied_name_string])
      end
      db_names = "%s" % names.join(',')
      new_names = Item.connection.select("
        select id, name
        from name_strings
        where name in (%s)
          and resolved = 0" % db_names)
      if new_names.first
        ids = new_names.map do |n|
          n['id']
        end.join(',')
        names = new_names.inject({}) do |res, n|
          res[n['name']] = n['id']
          res
        end
        Item.connection.execute("
                  update name_strings
                  set resolved = 1
                  where id in (%s)" % ids)
        resolved.each do |n|
          name = n[:supplied_name_string]
          if name_string_id = names[name]
            save_resolved_data(n, name_string_id)
          end
        end
      end
    end

    def save_resolved_data(n, name_string_id)
      data = prepare_resolved_data(n, name_string_id)
      Item.connection.execute("insert into resolved_name_strings
                (name_string_id, name, current_name,
                 classification, ranks, canonical_form_id,
                 in_curated_sources, data_sources_num,
                 match_type, data_source_id, data_source) values
                 (%s, %s, %s,
                  %s, %s, %s,
                  %s, %s, %s, %s, %s)" % data)
      id = Item.connection.select_value("select last_insert_id() as id")
      outlink_data = prepare_outlink_data(id, n[:preferred_results])
      outlink_data.each do |e|
        Item.connection.execute("insert into outlinks
                (resolved_name_string_id, name, url)
                values
                (%s, %s, %s)" % e)
      end
    end

    def get_canonical_form_id(name)
      name = Item.connection.quote(name)
      id = Item.connection.select("
          select id
          from canonical_forms
          where name = %s" % name).first
      if id
        id['id']
      else
        Item.connection.execute("insert into canonical_forms (name) values
                  (%s)" % name)
        Item.connection.select_value("select last_insert_id() as id limit 1")
      end
    end

    def add_name_strings(n)
      name = Item.connection.quote(n[:identifiedName])
      sci_name = Item.connection.quote(n[:scientificName])
      name_exists = Item.connection.execute("select 1
                               from name_strings
                               where name = %s" % sci_name).first
      if name_exists
        Item.connection.execute("update name_strings set expanded_abbr = 0
                  where name = %s" % name) if name == sci_name
      else
        expanded = (name == sci_name) ? 0 : 1
        Item.connection.execute("insert into name_strings (name, expanded_abbr)
                  values (%s, %s)" %
                [sci_name, expanded])
      end
              # [n[:verbatim], n[:scientificName], n[:identifiedName]]
    end


  def prepare_resolved_data(n, name_string_id)
    r = n[:results].first
    name = r[:name_string]
    current_name = r[:current_name]
    data_source_id = r[:data_source_id]
    data_source = r[:data_source_title]
    classification = r[:classification_path]
    ranks = r[:classification_path_ranks]
    canonical_form_id = get_canonical_form_id(r[:canonical_form])
    in_curated_sources = n[:in_curated_sources] ? 1 : 0
    data_sources_num = n[:data_sources_number]
    match_type = r[:match_type]
    [name_string_id, name, current_name, classification, ranks,
     canonical_form_id, in_curated_sources, data_sources_num,
     match_type, data_source_id, data_source].map { |n| quote(n) }
  end

  def quote(obj)
    return 'null' unless obj
    return obj if obj.is_a? Fixnum
    Item.connection.quote(obj)
  end


  def prepare_outlink_data(resolved_name_string_id, outlink_results)
    outlink_data = []
    outlink_results.each do |e|
      name = e[:name_string]
      url = e[:url]
      outlink_data << [resolved_name_string_id, name, url].map { |e| quote(e) }
    end
    outlink_data
  end



  end
end
