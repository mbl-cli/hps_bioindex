
class Item < ActiveRecord::Base
  has_many :bitstreams_items
  has_many :bitstreams, through: :bitstreams_items
  has_many :communities_items
  has_many :communities, through: :communities_items
end

class Bitstream < ActiveRecord::Base
  has_many :bitstreams_items
  has_many :items, through: :bitstreams_items
  has_many :bitstream_name_strings
  has_many :name_strings, through: :bitstream_name_strings
  
  def path
    dir = File.join(HpsBioindex.conf.harvest_dir,
              internal_id[0..1],
              internal_id[2..3],
              internal_id)
    FileUtils.mkdir_p(dir) unless File.exist?(dir) 
    File.join(dir, file_name)
  end
end

class BitstreamsItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :bitstream
end

class Community < ActiveRecord::Base
  has_many :communities_items
  has_many :items, through: :communities_items
end

class CommunitiesItem < ActiveRecord::Base
  belongs_to :community
  belongs_to :item
end

class NameString < ActiveRecord::Base
  has_many :resolved_name_strings
  has_many :bitstream_name_strings
  has_many :bitstreams, through: :bitstream_name_strings
end

class ResolvedNameString < ActiveRecord::Base
  belongs_to :name_string
  belongs_to :canonical_form
end

class CanonicalForm < ActiveRecord::Base
  has_many :resolved_name_strings
end

class BitstreamsNameString < ActiveRecord::Base
  belongs_to :bitstream
  belongs_to :name_string
end
