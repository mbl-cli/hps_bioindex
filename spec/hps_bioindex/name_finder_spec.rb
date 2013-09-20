require_relative '../spec_helper'

def prepare_data
  truncate_tables
  stub_request(:get, %r|/rest/updates/|).to_return(
    body: open(File.join(FILES_DIR, 'items_all_6.xml')))
  
  stub_request(:get, %r|/rest/communities/|).to_return(
    body: open(File.join(FILES_DIR, 'community_6.xml')))
  
  stub_request(:get, %r|/rest/items/|).to_return do |request|
    { body: get_item_file(request) }
  end
  
  stub_request(:get, %r|/rest/bitstream/|).to_return do |request|
    { body: open(File.join(FILES_DIR, 'bitstream_0.txt')) }
  end
    
  harvester = HpsBioindex::Harvester.new
  harvester.harvest(community_id: 6)
end

describe HpsBioindex::NameFinder do 
  let(:nf) { HpsBioindex::NameFinder.new(Bitstream.first) }
  before(:all) { prepare_data }
  
  it 'should exist' do
    nf.class.should == HpsBioindex::NameFinder
  end

  it 'should find_names' do
    Bitstream.count.should == 25
    File.exist?(HpsBioindex.conf.harvest_dir).should be_true
    url = "http://gnrd.example.org/name_finder.json?token=123"
    stub_request(:post, %r|/name_finder.json|).to_return(
      headers: {location: url}, status: 303)
    stub_request(:get, url).to_return(
      body: open(File.join(FILES_DIR, 'bitstream_0.txt.json')))

    k = Karousel.new(HpsBioindex::NameFinder, 10, 0)
    k.run
  end

end
