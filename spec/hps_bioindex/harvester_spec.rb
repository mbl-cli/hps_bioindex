require_relative '../spec_helper'

describe HpsBioindex::Harvester do
  let(:harvester) { HpsBioindex::Harvester.new }
  
  before(:all) { truncate_tables }

  def get_item_file(request)
    id = request.uri.path.match(%r|items/([\d]+)\.xml|)[1]
    open(File.join(FILES_DIR, "item_%s.xml" % id))
  end

  it 'should initiate' do
    harvester.class.should == HpsBioindex::Harvester
  end

  it 'should get updates from items of a community' do
    stub_request(:get, %r|/rest/updates/|).to_return(
      body: open(File.join(FILES_DIR, 'items_all_6.xml')))
    res = harvester.get_updates(community_id: 6)
    res.should_not be_nil
    res[:items_collection][:items].size.should == 26
  end

  it 'should store found items' do
    truncate_tables
    
    stub_request(:get, %r|/rest/updates/|).to_return(
      body: open(File.join(FILES_DIR, 'items_all_6.xml')))
    
    stub_request(:get, %r|/rest/communities/|).to_return(
      body: open(File.join(FILES_DIR, 'community_6.xml')))
    
    stub_request(:get, %r|/rest/items/|).to_return do |request|
      { body: get_item_file(request) }
    end
    
    stub_request(:get, %r|/rest/bitstream/|).to_return do |request|
      { body: open(File.join(FILES_DIR, 'bitstream_0.xhtml')) }
    end
    Item.count.should == 0
    Bitstream.count.should == 0
    harvester.harvest(community_id: 6)
    Item.count.should == 26
    Bitstream.count.should == 25
  end

  it 'should havest only new data' do
    truncate_tables
    
    stub_request(:get, %r|/rest/communities/|).to_return(
      body: open(File.join(FILES_DIR, 'community_6.xml')))
    stub_request(:get, %r|/rest/updates/|).to_return(
      body: open(File.join(FILES_DIR, 'items_all_6.xml')))
    stub_request(:get, %r|/rest/items/|).to_return do |request|
      { body: get_item_file(request) }
    end
    stub_request(:get, %r|/rest/bitstream/|).to_return do |request|
      { body: open(File.join(FILES_DIR, 'bitstream_0.xhtml')) }
    end

    res = harvester.harvest(community_id: 6)
    Item.count.should == 26
    Bitstream.count.should == 25
    Item.find(9587).last_modified.to_s.should == '2013-08-02 18:12:46 UTC'
    stub_request(:get, %r|/rest/updates/|).to_return(
      body: open(File.join(FILES_DIR, 'items_20130805_6.xml')))
    res = harvester.harvest(community_id: 6, 
                            timestamp: '2013-08-05 18:26:38 UTC')
    Item.count.should == 31
    Bitstream.count.should == 30
    Item.find(9587).last_modified.to_s.should == '2013-09-06 20:03:08 UTC'
  end

  it 'should not do bitstream harvest for duplicate harvests' do
    truncate_tables
    
    stub_request(:get, %r|/rest/communities/|).to_return(
      body: open(File.join(FILES_DIR, 'community_6.xml')))
    stub_request(:get, %r|/rest/updates/|).to_return(
      body: open(File.join(FILES_DIR, 'items_all_6.xml')))
    stub_request(:get, %r|/rest/items/|).to_return do |request|
      { body: get_item_file(request) }
    end
    stub_request(:get, %r|/rest/bitstream/|).to_return do |request|
      { body: open(File.join(FILES_DIR, 'bitstream_0.xhtml')) }
    end
    res = harvester.harvest(community_id: 6)
    Item.count.should == 26
    Bitstream.count.should == 25
    Item.find(9587).last_modified.to_s.should == '2013-08-02 18:12:46 UTC'
    FileUtils.rm_rf(HpsBioindex.conf.harvest_dir)
    res = harvester.harvest(community_id: 6)
    Item.count.should == 26
    Bitstream.count.should == 25
    File.exists?(HpsBioindex.conf.harvest_dir).should be false
  end
end

  
