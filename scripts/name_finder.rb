#!/usr/bin/env ruby
require 'optparse'
 
OPTS = {}
OptionParser.new do |o|
  o.on('-n') { |bool| OPTS[:new] = bool }
  o.on('-e ENVIRONMENT') { |env| OPTS[:environment] = env }
  o.on('-h') { puts o; exit }
  o.parse!
end

ENV['HPS_ENV'] = OPTS[:environment] || 'development'

require_relative '../lib/hps_bioindex'

HpsBioindex.logger = Logger.new($stdout)

HpsBioindex::NameFinder.reopen_errors

k = Karousel.new(HpsBioindex::NameFinder, 10, 20)

k.run  do 
  puts k.seats.map {|s| "%s, %s" % [s, s.finished?]}
end

norg = HpsBioindex::NameOrganizer.new

norg.organize

