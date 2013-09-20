require 'coveralls'
Coveralls.wear!

require 'find'
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

def prepare_name_data
  truncate_tables
  stub_request(:get, %r|/rest/updates/|).to_return(
    body: open(File.join(FILES_DIR, 'items_all_6.xml')))
  
  stub_request(:get, %r|/rest/communities/|).to_return(
    body: open(File.join(FILES_DIR, 'community_6.xml')))
  
  stub_request(:get, %r|/rest/items/|).to_return do |request|
    { body: get_item_file(request) }
  end
  
  stub_request(:get, %r|/rest/bitstream/|).to_return do |request|
    { body: open(File.join(FILES_DIR, 'bitstream_0.txt')) }
  end
    
  harvester = HpsBioindex::Harvester.new
  harvester.harvest(community_id: 6)
end

def run_name_finder
  url = "http://gnrd.example.org/name_finder.json?token=123"
  stub_request(:post, %r|/name_finder.json|).to_return do |request|
    { headers: {location: url}, status: 303 } 
  end
  stub_request(:get, url).to_return(
    body: open(File.join(FILES_DIR, 'bitstream_0.txt.json')))

  k = Karousel.new(HpsBioindex::NameFinder, 3, 0)
  k.run 
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
