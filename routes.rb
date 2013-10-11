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
    if params[:search_term]
      @names = CanonicalForm.where("name like '%s%%'" % params[:search_term]).
        order(:name)

    else
      @names = CanonicalForm.all.sort_by(&:name)
    end
    @names.each do |name|
       outlink = Outlink.select(:url).
         joins('join resolved_name_strings
           on resolved_name_strings.id = resolved_name_string_id').
         joins('join canonical_forms
           on canonical_forms.id =
             resolved_name_strings.canonical_form_id').
         where("canonical_forms.id = %s" % name.id).first
       # if outlink
       #   eol_id = outlink.url.match(%r|/pages/([\\d]+)|)[1]
       #   @eol = RestClient.get(
       #     "http://eol.org/api/pages/1.0/%s.json?" % eol_id +
       #     "images=1&subjects=overview&licenses=all&" +
       #     "&common_names=true&synonyms=true&details=true")
       # end
    end
    haml :names
  end

  get '/names/:name_id' do
    @name = CanonicalForm.where(id: params[:name_id]).first
    @bitstreams = @name.bitstreams if @name

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

