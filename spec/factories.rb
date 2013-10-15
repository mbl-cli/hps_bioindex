FactoryGirl.define do

  sequence(:num) { |n| n }

  sequence(:file_name) do |n| 
    file_name = 'file_n' 
    ext = ['xhtml', 'xml', 'jpg', 'pdf'].shuffle[0]
    file_name << ".%s" % ext
  end

  factory :item do
    id { FactoryGirl.generate(:num) }
    last_modified Time.now - 100000000
    resource  { "/rest/items/%s.xml" % id }
  end

  factory :bitstream do
    id { FactoryGirl.generate(:num) }
    file_name FactoryGirl.generate(:file_name)
  end

  factory :bitstreams_item do
    id { FactoryGirl.generate(:num) }
    bitstream
    item
  end

  factory :community do
    id { FactoryGirl.generate(:num) }
    name { "Community #%s" % id }
  end
  
  factory :communities_item do
    id { FactoryGirl.generate(:num) }
    community
    item
  end

  factory :name_string do
    id { FactoryGirl.generate(:num) }
    name = 'Namus stringus Linnaeus 1586'
    expanded_abbr = false
    resolved = true
  end
  
  factory :canonical_form do 
    id { FactoryGirl.generate(:num) }
    name = 'Namus stringus'
  end

  factory :resolved_name_string do
    id { FactoryGirl.generate(:num) }
    name_string
    canonical_form
    name 'Namus stringus L, 1586'
    data_source_id = 1
    data_source = 'Encyclopedia of Life'
    current_name = 'Namus stringus L. 1586'
    classification = ''
    ranks = ''
    in_curated_sources = true
    data_sources_num = 42
    match_type = 1
  end

  factory :outlink do
    id { FactoryGirl.generate(:num) }
    resolved_name_string
    name = 'Namus stringus Linnaeus, 1786'
    url = 'http://eol.org/pages/2'
    local_id = 2
  end

  factory :eol_data do
    id { FactoryGirl.generate(:num) }
    outlink
    image_url = 'http://example.org/image.jpg'
    thumbnail_url = 'http://example.org/thumbnail.jpg'
    overview = 'Lorum ipsum'
  end

  factory :eol_data_synonym do
    id { FactoryGirl.generate(:num) }
    eol_data
    name = 'Synonymus vulgaris'
    type = 'synonym'
  end

  factory :eol_data_vernacular do
    id { FactoryGirl.generate(:num) }
    eol_data
    name = 'Red tiger'
    language = 'en'
  end

end
