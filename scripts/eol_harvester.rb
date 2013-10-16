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

HpsBioindex.logger = Logger.new($stdout)

harvester = HpsBioindex::EolHarvester.new()

harvester.harvest  



