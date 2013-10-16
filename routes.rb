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
    search_term =  params[:search_term] || 'a'
    page = (params[:page] || 1)  
    @names = CanonicalForm.where("name like '%s%%'" % search_term).
        order(:name)
    haml :names
  end

  get '/names/:name_id' do
    @name = CanonicalForm.where(id: params[:name_id]).first
    @bitstreams = @name.bitstreams if @name

    haml :name
  end

  get '/' do
    haml :home
  end

end

