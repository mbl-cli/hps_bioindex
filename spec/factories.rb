FactoryGirl.define do

  sequence(:num) { |n| n }

  sequence(:file_name) do |n| 
    file_name = 'file_n' 
    ext = ['xhtml', 'xml', 'jpg', 'pdf'].shuffle[0]
    file_name << ".%s" % ext
  end

  factory :item do
    id FactoryGirl.generate(:num)
    last_modified Time.now - 100000000
    resource  { "/rest/items/%s.xml" % id }
  end

  factory :bitstream do
    id FactoryGirl.generate(:num)
    file_name FactoryGirl.generate(:file_name)
  end

  factory :bitstreams_item do
    bitstream
    item
  end

  factory :community do
    id FactoryGirl.generate(:num)
    name { "Community #%s" % id }
  end
  
  factory :communities_item do
    community
    item
  end

end
