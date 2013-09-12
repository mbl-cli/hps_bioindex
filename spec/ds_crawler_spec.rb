require 'spec_helper'

describe DsCrawler do
  
  let(:ds) { DsCrawler }

  describe '.version' do
    it 'should return version' do
      ds.version.should =~ /\d+\.\d+\.\d+/
      ds::VERSION.should == DsCrawler.version
    end
  end

  describe '.env' do
    it 'should return environment' do
      ds.env.should == :test
      ->{ ds.env = :wrongenv }.should raise_error
    end
  end

  describe '.config' do
    it 'should return config data' do
      ds.conf.dspace_api_url.should == 'http://example.org'
      ds.conf.harvest_dir.should == '/tmp/ds_crawler'
      ds.conf.api_key_public.should == '123'
      ds.conf.api_key_private.should == '456'
    end
  end

  describe '.logger=' do
    it 'should create and use logger' do
      ds.logger = Logger.new($sterr)
      ds.logger.class.should == Logger
    end
  end

end

