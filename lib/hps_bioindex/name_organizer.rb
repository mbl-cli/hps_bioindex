module HpsBioindex
  class NameOrganizer
    def organize
      Item.transaction do
        import_names
      end
    end

    private

    def import_names
      Bitstream.all.each do |b|
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
