#!/usr/bin/env ruby

ENV['HPS_ENV'] ||= (ENV['RACK_ENV'] || :development)

require 'zen-grids'
require 'rack/timeout'
require 'sinatra'
require 'sinatra/base'
require 'haml'
require 'sass'

require_relative 'lib/hps_bioindex'
require_relative 'routes'


class HpsBioindexApp < Sinatra::Base
  
  configure do
    Compass.add_project_configuration(File.join(File.dirname(__FILE__),  
                                                'config', 

                                                'compass.config'))    

    use Rack::MethodOverride
    use Rack::Timeout
    Rack::Timeout.timeout = 9_000_000

    use Rack::Session::Cookie, secret: HpsBioindex.conf.session_secret

    set :scss, Compass.sass_engine_options
  end

  helpers do 
    include Rack::Utils
    alias_method :h, :escape_html
  end 

end

run HpsBioindexApp.new if HpsBioindexApp.app_file == $0

