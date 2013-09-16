module HpsBioindex
  class Harvester

    def initialize
      @api = HpsBioindex::DspaceApi.new
    end

    def harvest(opts = {})
      HpsBioindex.logger.info("Starting harvest from community '%s'" %
                              get_community(opts))
      res = get_updates(opts)
      if defined?(res[:items_collection][:items].size) &&
        res[:items_collection][:items].size > 0
        items = res[:items_collection][:items]
        items = [items] unless items.is_a?(Array)
        items.each do |item|
          store_item(item)
        end
      end
      get_bitstreams
    end
    
    def get_updates(opts = {})
      HpsBioindex.logger.info('Getting new items')
      params = updates_params(opts)
      res = @api.updates.get(params: params)
      res =~ /xml/ ? Hash.from_xml(res) : nil
    end

    private

    def updates_params(opts)
      community_id = opts[:community_id].to_i > 0 ?
        opts[:community_id].to_i.to_s : nil
      timestamp = opts[:timestamp] || '1970-01-01'
      args = { api_key: @api.key,
               api_digest: @api.digest(@api.updates_path),
               timestamp: timestamp,
             }
      args.merge!(community: community_id) if community_id
      args
    end
    
    def store_item(an_item)
      db_item = Item.find(an_item[:id]) rescue nil
      if db_item 
         if db_item.last_modified < Time.parse(an_item[:last_modified])
           db_item.update(last_modified: an_item[:last_modified], 
                          harvested: false)
           db_item.save!
         end
      else
        Item.create(id: an_item[:id], 
                  last_modified: an_item[:last_modified], 
                  resource: "/rest/items%s.xml" % an_item[:id],
                  harvested: false,
                 )
      end
    end

    def get_bitstreams
      Item.where(harvested: false).
        order(:last_modified).each_with_index do |item, i|
        HpsBioindex.logger.
          info("Processing bitstreams for item %s from %s" % 
               [i, item[:last_modified]]) if i % 10 == 0
        path = "/rest/items/%s.xml" % item.id
        params = { api_key: @api.key, api_digest: @api.digest(path) }
        item_xml = @api.site[path].get(params: params)
        item_hash = Hash.from_xml(item_xml)
        process_bitstreams(item_hash, item)
        item.harvested = true
        item.save!
      end
    end

    def process_bitstreams(item_hash, item)
      bitstreams = item_hash[:items][:bitstreams][:bitstreamentity]
      bitstreams = [bitstreams] unless bitstreams.is_a?(Array)
      bitstreams.each do |b|
        next unless (b[:name] && b[:name].is_a?(String) && 
          b[:name].match(/\.(xhtml|html|txt)$/))
        db_b = Bitstream.find(b[:id]) rescue nil
        if db_b
          db_b.update(file_name: b[:name], mime_type: b[:mimeType])
        else
          db_b = Bitstream.create(id: b[:id], 
                                  file_name: b[:name], 
                                  mime_type: b[:mimeType], 
                                  internal_id: b[:checkSum] )
          if BitstreamsItem.where(bitstream_id: db_b.id, 
                                     item_id: item_hash[:id]).empty?
            BitstreamsItem.create(bitstream_id: db_b.id, 
                                  item_id: item.id)
          end
          item.update(harvested: true)
          item.save!
        end
        download_bitstream(db_b)
      end
    end
  
    def download_bitstream(bitstream)
      path = "/rest/bitstream/%s" % bitstream.id
      w = open(bitstream.path, 'wb')
      params = { api_key: @api.key, api_digest: @api.digest(path) }
      w.write(@api.site[path].get(params: params))
      w.close
    end

    def get_community(opts)
      if opts[:community_id]
        res = @api.site["/rest/communities/%s.xml" % opts[:community_id]].get
        res = Hash.from_xml(res)
        if defined?(res[:communities][:name].size)
        res[:communities][:name] 
        else
          raise RuntimeError.new("Cannot find community with id %s" %
                                      opts[:community_id])
        end
      else
        raise ArgumentError.new("havest needs community_id parameter")
      end
    end

  end
end
