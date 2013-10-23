#!/usr/bin/env ruby
require 'optparse'
 
OPTS = {}
OptionParser.new do |o|
  o.on('-e ENVIRONMENT') { |env| OPTS[:environment] = env }
  o.on('-h') { puts o; exit }
  o.parse!
end

ENV['HPS_ENV'] = OPTS[:environment] || 'development'

require_relative '../lib/hps_bioindex'

# %w(eol_data eol_data_vernaculars eol_data_synonyms).each do |t|
#   Item.connection.execute("truncate table %s" % t)
# end

HpsBioindex.logger = Logger.new($stdout)

eol_dwca = HpsBioindex::EolDwca.new()

eol_dwca.process 




