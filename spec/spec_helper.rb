require 'coveralls'
Coveralls.wear!

require 'factory_girl'

ENV['DS_ENV'] = 'test'
require_relative '../lib/hps_bioindex'

RSpec.configure do |c|
  c.mock_with :rr
end

def truncate_tables
  ['items', 'bitstreams', 'bitstreams_items'].each do |t|
    ActiveRecord::Base.connection.execute("truncate table %s" % t)
  end
end

unless defined?(DS_CONSTANTS)
  ITEMS_ALL_6 = File.read(File.join(File.dirname(__FILE__), 
                                    'files', 'items_all_6.xml'))
  ITEMS_20130805_6 = File.read(File.join(File.dirname(__FILE__), 
                                    'files', 'items_20130805_6.xml'))
  DS_CONSTANTS = true
end

FactoryGirl.find_definitions
