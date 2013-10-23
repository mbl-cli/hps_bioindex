module HpsBioindex
  class EolDwca

    def self.uuid(a_string)
      gn_seed = UUID.create_v5("globalnames.org", UUID::NameSpace_DNS)
      UUID.create_v5(a_string, gn_seed).to_s
    end

    def initialize
      @uuid = '047d69f8-9f67-4436-9a37-2e1bd75f7279'
      @path = File.expand_path(File.join(File.dirname(__FILE__), 
                                         '..', '..', 
                                         '/public/dwca/eol_dwca.tar.gz'))
      @data = get_data
      get_core
      get_extensions
      @eml = make_eml
    end

    def process
      HpsBioindex::logger.info('Making EOL\'s DarwinCore Archive file')
      gen = DarwinCore::Generator.new(@path)
      gen.add_core(@core, 'taxa.csv')
      @extensions.each_with_index do |extension, i|
        gen.add_extension(extension[:data], 
                          extension[:file_name], 
                          true, 
                          extension[:row_type])
      end
      gen.add_meta_xml
      gen.add_eml_xml(@eml)
      gen.pack
      HpsBioindex::logger.info('DarwinCore Archive file is created')
    end


    private

    def get_data
      items_names = Item.connection.select_rows("
        select item_id, value 
        from metadata 
        where `schema` = 'dwc' 
          and `element` = 'scientificName' 
          and `qualifier` = 'eol'
          ")
          get_taxon_ids(items_names) 
    end

    def get_taxon_ids(items_names)
      res = {}
      items_names.each do |item_id, name|
        uuid = EolDwca.uuid(name).to_s
        res[uuid] ? 
          res[uuid][:items] << Item.where(id: item_id).first :
          res[uuid] = { name: name, items: [Item.where(id: item_id).first] }
      end
      res
    end

    def get_core
      @core = [['http://rs.tdwg.org/dwc/terms/taxonID',
        'http://rs.tdwg.org/dwc/terms/scientificName']]
      @data.each do |key, value|
        @core << [key.dup, value[:name]]
      end
    end

    def get_extensions
      @extensions = []
      @extensions << {
        data: [[
          'http://rs.tdwg.org/dwc/terms/taxonID',
          'http://purl.org/dc/terms/title',
          'http://purl.org/dc/terms/creator',
          'http://purl.org/dc/terms/description',
          'http://rs.tdwg.org/ac/terms/furtherInformationURL',
      ]], 
        file_name: 'hps_data.csv',
        row_type: 'http://eol.org/schema/media/Document',
      }
      @data.each do |key, value|
        value[:items].each do |item|
          process_data_item(key, item)
        end
      end
    end

    def process_data_item(taxon_id, current_item)
      metadata = current_item.metadata.inject({}) do |res, m|
        if m.schema == 'dc'
          term = (m.qualifier && m.qualifier.strip =~ /^[a-zA-Z0-9]+$/) ? 
            "%s.%s" % [m.element.strip, m.qualifier.strip] : m.element.strip
          res[term] = m.value
        end
        res
      end

      @extensions[-1][:data] << [
        taxon_id,
        (metadata['title'] || metadata['title.alternative']),
        metadata['creator'],
        metadata['abstract'],
        metadata['identifier.uri'],
      ]
    end

    def make_eml
      {
        id: @uuid,
        title: 'History and Philosofy of Science Repository',
        authors: [
          { email: 'jdoe at example dot com' }
      ],
        metadata_providers: [
          { first_name: 'John',
            last_name:  'Doe',
            email:      'jdoe@example.com' }
      ],
        abstract: 'Digital History and Philosophy of Science (dHPS) brings '\
        'together historians and philosophers of science, with '\
        'informaticians, computer scientists, and reference '\
        'librarians with the goal of thinking of new ways to '\
        'integrate traditional scholarship with digital tools and'\
        'resources.',
        url: HpsBioindex.conf.hps_url 
      }
    end
  end
end
