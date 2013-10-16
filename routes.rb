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

  get '/names.?:format?' do
    search_term =  params[:search_term] || 'a'
    page = (params[:page] || 1)  
    batch_size = params[:batch_size] || 20;
    @names = CanonicalForm.where("name like '%s%%'" % search_term).
        order(:name).limit(batch_size)
    case params[:format]
    when 'json'
      content_type 'application/json', charset: 'utf-8'
      names_json = @names.to_json
      if params[:callback]
        names_json = "%s(%s)" % [params[:callback], names_json]
      end
      names_json
    else
      @names.size > 1 ? haml(:names) : redirect("/names/%s" % @names.first.id)
    end
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

