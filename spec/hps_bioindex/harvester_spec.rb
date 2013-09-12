require_relative '../spec_helper'

describe HpsBioindex::Harvester do
  let(:harvester) { HpsBioindex::Harvester.new }
  before(:all) { truncate_tables }

  it 'should initiate' do
    harvester.class.should == HpsBioindex::Harvester
  end

  it 'should get updates from items of a community' do

    any_instance_of(RestClient::Resource) do |klass|
        stub(klass).get { ITEMS_ALL_6 }
    end

    res = harvester.get_updates(community_id: 6)
    res.should_not be_nil
    res[:items_collection][:items].size.should == 31
  end

  it 'should store found items' do
    # truncate_tables
    # any_instance_of(RestClient::Resource) do |klass|
    #     stub(klass).get { ITEMS_ALL_6 }
    # end
    # Item.count.should == 0
    # harvester.harvest(community_id: 6)
    # Item.count.should == 31
  end

end
