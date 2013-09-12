
class Item < ActiveRecord::Base
  has_many :bitstreams_items
  has_many :bitstreams, through: :bitstreams_items
end

class Bitstream < ActiveRecord::Base
  has_many :bitstreams_items
  has_many :items, through: :bitstreams_items
  
  def path
    dir = File.join(DsCrawler.conf.harvest_dir,
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


