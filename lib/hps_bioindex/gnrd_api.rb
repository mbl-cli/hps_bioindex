module HpsBioindex
  class GnrdApi
    attr :name_finder_path

    def initialize
      @name_finder_path = '/name_finder.json'
    end

    def site
      @@site ||= RestClient::Resource.new(HpsBioindex.conf.name_finding_url)
    end

    def name_finder
      site[@name_finder_path]
    end

    def name_finder_params
      @params ||= {
        unique: 'false', 
        verbatim: 'true', 
        detect_language: 'false',
        all_data_sources: 'true',
        best_match_only: 'true',
        preferred_data_sources: '12',
      }
    end
  end
end

