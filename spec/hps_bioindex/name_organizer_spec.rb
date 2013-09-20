require_relative '../spec_helper'

describe HpsBioindex::NameOrganizer do

  it 'should exist' do
    norg = HpsBioindex::NameOrganizer.new
    norg.class.should == HpsBioindex::NameOrganizer
  end
  
  it 'should organize name files' do
    run_name_finder
    NameString.count.should == 0
    norg = HpsBioindex::NameOrganizer.new
    norg.organize 
    NameString.count.should == 67
    Outlink.count. should == 54
    CanonicalForm.count.should == 62

    # idempotency
    norg.organize 
    NameString.count.should == 67
    Outlink.count. should == 54
    CanonicalForm.count.should == 62
  end

end
