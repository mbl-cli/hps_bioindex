module HpsBioindex

  class NameFinder < Karousel::ClientJob
    
    attr_accessor :status

    STATUS = { init: 1 }

    @@bitstreams = nil
   
    def self.populate(karousel_size)
      get_all_docs unless @@bitstreams
      res = []
      karousel_size.times { res << @@bitstreams.shift }
      res.compact
    end
    
    def initialize(bitstream)
      @bitstream = bitstream
      @api = GnrdApi.new
      @status = STATUS[:init]
      @url = nil
    end

    def send
      params = @api.name_finder_params.merge(file: File.new(@bitstream.path, 
                                                            'r:utf-8'))
      @api.name_finder.post(params) do |response, request, result, &block|
        if [302, 303].include? response.code
          @url = response.headers[:location]
          true
        else
          false
        end
      end
    end
  
    def finished?
      HpsBioindex.logger.info("Checking for %s, %s" % 
                              [@bitstream.file_name, @url]) 
      @res = RestClient.get(@url)
      @names = JSON.parse(@res, :symbolize_names => true)[:names]
      !!@names
    end
  
    def process
      HpsBioindex.logger.info("Saving names for %s" % @bitstream.file_name) 
      w = open(@bitstream.path + '.json', 'w:utf-8')
      w.write(JSON.pretty_generate(JSON.parse(@res)))
      w.close
      @bitstream.name_processed = true
      @bitstream.save!
    end

    private

    def self.get_all_docs
      @@bitstreams = []
      Bitstream.where(name_processed: false).each do |b|
        @@bitstreams << NameFinder.new(b)
      end
    end

  end
end

