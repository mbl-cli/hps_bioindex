module DsCrawler
  class DspaceApi
    attr :updates_path

    def initialize
      @updates_path = '/rest/updates/items.xml'
    end

    def site
      @@site ||= RestClient::Resource.new(DsCrawler.conf.dspace_api_url)
    end

    def updates
      site[@updates_path]
    end

    def key
      if DsCrawler.conf.api_key_public.to_s == ''
        raise NameError.new('No public key in config') 
      else
        DsCrawler.conf.api_key_public
      end
    end
    
    def digest(path)
      if DsCrawler.conf.api_key_private.to_s == ''
        raise NameError.new('No private key in config')
      else
        api_key_private = DsCrawler.conf.api_key_private
        Digest::SHA1.hexdigest(path + api_key_private)[0..7] 
      end
    end

  end
end
