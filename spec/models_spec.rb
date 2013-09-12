require 'spec_helper'

describe Item do
  let(:item) { FactoryGirl.create(:item) }
  before(:all) { truncate_tables }
  
  it 'should work' do
    item.class.should == Item
    Item.count.should == 1
  end

end

describe Bitstream do
  let(:bitstream) { FactoryGirl.create(:bitstream) }
  before(:all) { truncate_tables }
  
  it 'should work' do
    bitstream.class.should == Bitstream
    Bitstream.count.should == 1
  end

end

describe BitstreamsItem do
  
  it 'should work' do
    truncate_tables
    FactoryGirl.create(:bitstreams_item)
    Bitstream.count.should == 1
    Item.count.should == 1
    Item.first.bitstreams.first.should == Bitstream.first
    Bitstream.first.items.first.should == Item.first
  end
end
