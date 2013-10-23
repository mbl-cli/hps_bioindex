class HpsBioindexApp < Sinatra::Base

  get '/css/:filename.css' do
    scss :"sass/#{params[:filename]}"
  end

  get '/documents' do
    Bitstream.includes(:items)
    @bitstreams = Bitstream.all
    haml :documents
  end
  
  get '/documents/:doc_id' do
    @bitstream = Bitstream.where(id: params[:doc_id]).first
    @bitstream_text = File.read(@bitstream.path + '.tagged')
    haml :document
  end

  get '/names.?:format?' do
    search_term =  params[:search_term] || 'a'
    batch_size = (params[:batch_size] || 10_000).to_i
    page = (params[:page] || 1).to_i
    offset = (page-1) * batch_size
    is_exact_search = params[:exact_search] == 'true'
    if is_exact_search
      @names = CanonicalForm.where(name: search_term).where(show: true)
    else
      @names = CanonicalForm.where("name like '%s%%' and `show` = 1" % search_term).
        order(:name).offset(offset).limit(batch_size)
    end
    case params[:format]
    when 'json'
      content_type 'application/json', charset: 'utf-8'
      names_json = @names.to_json
      if params[:callback]
        names_json = "%s(%s)" % [params[:callback], names_json]
      end
      names_json
    else
      @names.size == 1 ? redirect("/names/%s" % @names.first.id) : haml(:names)
    end
  end

  get '/names/:name_id' do
    @name = CanonicalForm.where(id: params[:name_id]).first
    @eol_url, @google_url, @eol_data = name_details(@name)
    @bitstreams = @name.bitstreams if @name
    haml :name
  end

  get '/' do
    items_by_decade = get_items_by_decade
    # @names_by_decade = get_names_by_decade(items_by_decade)
    haml :home
  end

end

