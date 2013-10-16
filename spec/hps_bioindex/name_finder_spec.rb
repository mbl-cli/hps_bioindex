require_relative '../spec_helper'

describe HpsBioindex::NameFinder do 
  let(:nf) { HpsBioindex::NameFinder.new(Bitstream.first) }
  before(:all) { prepare_name_data }
  
  it 'should exist' do
    nf.class.should == HpsBioindex::NameFinder
  end

  it 'should find_names' do
    Bitstream.count.should == 25
    count = 0
    File.exist?(HpsBioindex.conf.harvest_dir).should be_true
    url = "http://gnrd.example.org/name_finder.json?token=123"
    stub_request(:post, %r|/name_finder.json|).to_return do |request|
      { headers: {location: url}, status: 303 } 
    end
    stub_request(:get, url).to_return(
      body: open(File.join(FILES_DIR, 'bitstream_0.txt.json')))

    stub_request(:get, %r|eol.org/api/pages/1.0/|).
      to_return do |request|
      { body: get_eol_file(request) }
    end
    
    k = Karousel.new(HpsBioindex::NameFinder, 3, 0)
    k.run do
    end
    json_files = Find.find(HpsBioindex.conf.harvest_dir).
      select {|d| d =~ /json$/}
    json_files.size.should == 25

    tagged_files = Find.find(HpsBioindex.conf.harvest_dir).
      select {|d| d =~ /_tagged$/}
    tagged_files.size.should == 0

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
    tagged_files = Find.find(HpsBioindex.conf.harvest_dir).
      select {|d| d =~ /\.tagged$/}
    tagged_files.size.should == 25
  end

end
