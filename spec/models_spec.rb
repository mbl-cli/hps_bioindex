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

describe Community do
  let(:community) { FactoryGirl.create(:community) }
  before(:all) { truncate_tables }

  it 'should work' do
    community.class.should == Community
    Community.count.should == 1
  end
end

describe CommunitiesItem do
  let(:communities_item) { FactoryGirl.create(:communities_item) }
  before(:all) { truncate_tables }

  it 'should work' do
    communities_item.class.should == CommunitiesItem
    CommunitiesItem.count.should == 1
    Community.count.should == 1
    Item.count.should == 1
  end
end

describe EolData do
  let(:eol_data) { FactoryGirl.create(:eol_data) }
  before(:all) { truncate_tables }
  
  it 'should work' do
    eol_data.class.should == EolData 
    EolData.count.should == 1
    Outlink.count.should == 1
    ResolvedNameString.count.should == 1
    CanonicalForm.count.should == 1
    NameString.count.should == 1
  end
end

describe EolDataSynonym do
  let(:eol_data_synonym) { FactoryGirl.create(:eol_data_synonym) }
  before(:all) { truncate_tables }

  it 'should work' do
    eol_data_synonym.class.should == EolDataSynonym
    EolData.count.should == 1
    EolDataSynonym.count.should == 1
  end
end

describe EolDataVernacular do
  let(:eol_data_vernacular){ FactoryGirl.create(:eol_data_vernacular) }
  before(:all) { truncate_tables }

  it 'should work' do
    eol_data_vernacular.class.should == EolDataVernacular
    EolData.count.should == 1
    EolDataVernacular.count.should == 1
  end
end
