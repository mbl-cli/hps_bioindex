require_relative 'spec_helper'

describe Hash do
  it 'should create hash from xml' do
    xml_txt = File.read(File.join(FILES_DIR, 'items_all_6.xml'))
    hash = Hash.from_xml(xml_txt)
    hash[:items_collection][:items].first.should == 
      { id: 9587, 
        entityReference: '/items/9587', 
        last_modified: '2013-08-02 18:12:46 UTC', 
        entityId: 9587 }
  end
end
