require_relative '../environment'
require_relative 'monkey_patches.rb'
require_relative '../models'
require_relative 'uuid'
require_relative 'hps_bioindex/errors'
require_relative 'hps_bioindex/version'
require_relative 'hps_bioindex/downloader'
require_relative 'hps_bioindex/harvester'
require_relative 'hps_bioindex/dspace_api'
require_relative 'hps_bioindex/name_finder'
require_relative 'hps_bioindex/gnrd_api'
require_relative 'hps_bioindex/name_organizer'
require_relative 'hps_bioindex/eol_harvester'
require_relative 'hps_bioindex/eol_dwca'

module HpsBioindex

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
