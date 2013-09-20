class HpsBioindexApp < Sinatra::Base

  get '/css/:filename.css' do
    scss :"sass/#{params[:filename]}"
  end

  get '/bitstreams' do
    @bitstreams = Bitstream.all
    haml :bitstreams
  end

  get '/' do
    require 'ruby-debug'; debugger
    haml :index
    # redirect '/bitstreams'
  end

end

