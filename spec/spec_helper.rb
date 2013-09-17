require 'coveralls'
Coveralls.wear!

require 'factory_girl'
require 'webmock/rspec'

ENV['HPS_ENV'] = 'test'
require_relative '../lib/hps_bioindex'

RSpec.configure do |c|
  c.mock_with :rr
end

def truncate_tables
  HpsBioindex::Harvester.nuke
end

def get_item_file(request)
  id = request.uri.path.match(%r|items/([\d]+)\.xml|)[1]
  open(File.join(FILES_DIR, "item_%s.xml" % id))
end

unless defined?(HPS_CONSTANTS)
  FILES_DIR = File.expand_path(File.join( File.dirname(__FILE__), 'files'))
  ITEMS_ALL_6 = File.read(File.join(File.dirname(__FILE__), 
                                    'files', 'items_all_6.xml'))
  ITEMS_20130805_6 = File.read(File.join(File.dirname(__FILE__), 
                                    'files', 'items_20130805_6.xml'))
  HPS_CONSTANTS = true
end

FactoryGirl.find_definitions
