module HpsBioindex
  class EolHarvester
    def harvest
      outlinks = Outlink.find_by_sql('
        select distinct o.*
        from outlinks o 
          left outer join eol_data ed 
            on ed.outlink_id = o.id 
        where ed.id is null')
      HpsBioindex.logger.info("Processing %s EOL pages" % outlinks.size)
      outlinks.each_with_index do |outlink, i|
        if (i+1) % 1 == 0
          HpsBioindex.logger.info("Getting info from %s'th EOL page" % (i+1))
        end

        populate_eol_data(outlink)
      end
    end

    private

    def populate_eol_data(outlink)
      eol_id = outlink.local_id
      eol_api_url = "http://eol.org/api/pages/1.0/%s.json?" % eol_id +
        'images=1&subjects=overview&licenses=all&' +
        'common_names=true&synonyms=true&details=true'
      if HpsBioindex.conf.eol_api_key
        eol_api_url += "&key=%s" % HpsBioindex.conf.eol_api_key
      end
      begin
        eol = RestClient.get(eol_api_url)
        sleep(0.5)
      rescue
        eol = nil
      end
      if eol && !EolData.find_by(outlink_id: outlink.id)
        eol = JSON.parse(eol, symbolize_names: true)
        image_url, thumbnail_url, overview = extract_eol_data(eol)
        overview = nil if overview && overview.size > 3000
        eol_data = EolData.create(outlink_id: outlink.id, image_url: image_url,
                             thumbnail_url: thumbnail_url, overview: overview)
        add_eol_synonyms(eol, eol_data)
        add_eol_vernaculars(eol, eol_data)
      end
    end

    def add_eol_synonyms(eol, eol_data)
      eol_data_id = eol_data.id
      if eol[:synonyms] && !eol[:synonyms].empty?
        eol[:synonyms].each do |s|
          EolDataSynonym.create(eol_data_id: eol_data_id,
                                name: s[:synonym], 
                                relationship: s[:relationship])
        end
      end
    end
    
    def add_eol_vernaculars(eol, eol_data)
      eol_data_id = eol_data.id
      if eol[:vernacularNames] && !eol[:vernacularNames].empty?
        eol[:vernacularNames].each do |v|
          EolDataVernacular.create(eol_data_id: eol_data_id,
                                   name: v[:vernacularName], 
                                   language: v[:language])
        end
      end
    end

    def extract_eol_data(eol_data)
      image_url = thumbnail_url = overview = nil
      if eol_data[:dataObjects] && !eol_data[:dataObjects].empty?
        eol_data[:dataObjects].each do |obj|
          if obj[:dataType] =~ /StillImage/
            image_url = obj[:eolMediaURL] unless image_url
            thumbnail_url = obj[:eolThumbnailURL] unless thumbnail_url
          end
          overview = obj[:description] if obj[:dataType] =~ /Text/
        end
      end
      [image_url, thumbnail_url, overview]
    end
  end
end
