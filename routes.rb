class HpsBioindexApp < Sinatra::Base

  get '/css/:filename.css' do
    scss :"sass/#{params[:filename]}"
  end

  get '/documents' do
    @bitstreams = Bitstream.all
    if params[:doc_id]
      @bitstream = Bitstream.where(id: params[:doc_id]).first
      @bitstream_text = File.read(@bitstream.path + '.tagged')
    end
    haml :documents
  end

  get '/names' do
    @names = CanonicalForm.all.sort_by(&:name)
    haml :names
  end

  get '/names/:name_id' do
    @name = CanonicalForm.where(id: params[:name_id]).first
    @bitstreams = @name.bitstreams if @name
    # @eol = RestClient.get("http://eol.org/api/pages/1.0/#{}.json?" +
    #                       "images=2&subjects=overview&licenses=all&" +
    #                       "&common_names=true&synonyms=true")

    haml :name
  end

  get '/' do
    @names = CanonicalForm.connection.select_values('
      select name
      from canonical_forms'
      )
    haml :home
  end

end

