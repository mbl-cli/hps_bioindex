class HpsBioindexApp < Sinatra::Base

  def combine_metadata_items
    return [] if @metadata.empty? and items.empty?
    matches = {}
    items_ids = (@metadata.map(&:item_id) + @items.map(&:id)).uniq.join(',')
    @metadata.each do |m|
      matches[m.item_id] ? 
        matches[m.item_id] << m :
        matches[m.item_id] = [m]
    end
    bitstreams = Bitstream.find_by_sql("
                          select bs.* 
                          from bitstreams bs 
                          join bitstreams_items bi
                            on bi.bitstream_id = bs.id
                          where bi.item_id in (%s)" %
                           items_ids)
    [bitstreams, matches]
  end

  get '/css/:filename.css' do
    scss :"sass/#{params[:filename]}"
  end

  get '/documents.?:format?' do
    search_term = params[:search_term]
    is_exact_search = params[:docs_exact_search] == 'true'
    Bitstream.includes(:items)
    if search_term
      if is_exact_search
        @metadata = Metadata.where(value: search_term)
        @items = Item.where(title: search_term)
        @bitstreams, @matches = combine_metadata_items
      else
        search_term = '[[:<:]]' + search_term
        @metadata = Metadata.where("value rlike ?", search_term)
        @items = Item.where("title rlike ?", search_term)
        @bitstreams, @matches  = combine_metadata_items
      end
    else
      @bitstreams = Bitstream.all
    end
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
      @names = CanonicalForm.
        where("name like '%s%%' and `show` = 1" % search_term).
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
    @vernacular = @eol_data ?  
      @eol_data.eol_data_vernaculars.select { |v| v.language == 'en' }.first :
      nil
    @bitstreams = @name.bitstreams if @name
    haml :name
  end

  get '/' do
    items_by_decade = get_items_by_decade
    # @names_by_decade = get_names_by_decade(items_by_decade)
    @names_count = CanonicalForm.count
    @documents_count = Item.count
    @most_found = CanonicalForm.most_found_names[0..9]
    @most_found_species = CanonicalForm.most_found_species_names[0..9]
    @decades = []
    (1890..Time.now.year).to_a.each_with_index do |e, i|
      @decades << e if i % 10 == 0
    end
    haml :home
  end

end

