require 'ostruct'
require 'yaml'
require 'digest'
require 'nokogiri'
require 'active_record'
require 'rest_client'
require 'karousel'
require 'tag_along'

module HpsBioindex

  def self.env
    @env ||= ENV['HPS_ENV'] ? ENV['HPS_ENV'].to_sym : :development
  end

  def self.env=(env)
    if [:development, :test, :production].include?(env)
      @env = env
    else
      raise TypeError.new('Wrong environment')
    end
  end

  def self.db_conf
    @db_conf ||= self.get_db_conf
  end

  def self.conf
    @conf ||= self.get_conf
  end

  def self.get_db_connection
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Base.logger.level = Logger::WARN
    ActiveRecord::Base.establish_connection(self.db_conf[self.env.to_s])
  end

  private

  def self.get_db_conf
    conf = File.read(File.join(File.dirname(__FILE__),
                          'config', 'config.yml'))
    @db_conf = YAML.load(conf)
  end

  def self.get_conf
    conf = self.db_conf[self.env.to_s]
    @conf = OpenStruct.new(
                            session_secret:   conf['session_secret'],
                            dspace_api_url:   conf['dspace_api_url'],
                            name_finding_url: conf['name_finding_url'],
                            harvest_dir:      conf['harvest_dir'],
                            api_key_public:   conf['api_key_public'].to_s,
                            api_key_private:  conf['api_key_private'].to_s,
                            communities:      conf['communities'],
                            adapter:          conf['adapter'],
                            host:             conf['host'],
                            username:         conf['username'],
                            password:         conf['password'],
                            database:         conf['database'],
                            eol_api:          '',
                           )
  end
end

HpsBioindex.get_db_connection
