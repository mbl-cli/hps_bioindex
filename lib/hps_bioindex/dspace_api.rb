module HpsBioindex
  class DspaceApi
    attr :updates_path

    def initialize
      @updates_path = '/rest/updates/items.xml'
    end

    def site
      @@site ||= RestClient::Resource.new(HpsBioindex.conf.dspace_api_url)
    end

    def updates
      site[@updates_path]
    end

    def key
      if HpsBioindex.conf.api_key_public.to_s == ''
        raise NameError.new('No public key in config') 
      else
        HpsBioindex.conf.api_key_public
      end
    end
    
    def digest(path)
      if HpsBioindex.conf.api_key_private.to_s == ''
        raise NameError.new('No private key in config')
      else
        api_key_private = HpsBioindex.conf.api_key_private
        Digest::SHA1.hexdigest(path + api_key_private)[0..7] 
      end
    end

  end
end
