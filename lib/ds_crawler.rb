require_relative '../environment'
require_relative 'monkey_patches.rb'
require_relative '../models'
require_relative 'ds_crawler/version'
require_relative 'ds_crawler/downloader'
require_relative 'ds_crawler/harvester'
require_relative 'ds_crawler/dspace_api'

module DsCrawler

  def self.version
    VERSION
  end

  def self.logger
    @logger ||= Logger.new('/dev/null')
  end

  def self.logger=(new_logger)
    @logger = new_logger
  end

end
