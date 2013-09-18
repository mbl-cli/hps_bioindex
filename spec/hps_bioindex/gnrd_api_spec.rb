require_relative '../spec_helper'

describe HpsBioindex::GnrdApi do
  let(:api) { HpsBioindex::GnrdApi.new }
  
  it 'should have site and name_finder_path' do
    api.site.class.should == RestClient::Resource
    api.name_finder_path.should == '/name_finder.json'
  end

  it 'should have name_finder resource' do
    api.name_finder.class.should == RestClient::Resource
    api.name_finder.url.should == 'http://gnrd.example.org/name_finder.json'
  end

  it 'should have params' do
    api.name_finder_params == {}
  end

end
