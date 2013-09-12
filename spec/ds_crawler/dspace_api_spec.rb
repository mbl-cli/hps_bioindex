require_relative '../spec_helper'

describe DsCrawler::DspaceApi do
  let(:api) { DsCrawler::DspaceApi.new }

  it 'should have site' do
    api.site.class.should == RestClient::Resource
    api.site['/rest/communities.xml'].url.should == 
      'http://example.org/rest/communities.xml'
  end

  it 'should have updates resource' do
    api.updates.class.should == RestClient::Resource
    api.updates.url.should == 'http://example.org/rest/updates/items.xml'
  end

  it 'should have public_key' do
    api.key.should == '123'
    stub(DsCrawler.conf).api_key_public { nil }
    -> { api.key }.should raise_error
  end

  it 'should make digest' do
    api.digest(api.updates_path).should == 'bee68db3'
    stub(DsCrawler.conf).api_key_private { nil }
    -> { api.digest(api.updates.url) }.should raise_error
  end

  it 'should know updates path' do
    api.updates_path.should == '/rest/updates/items.xml'
  end

end
