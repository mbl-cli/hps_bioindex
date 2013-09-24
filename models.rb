
class Item < ActiveRecord::Base
  has_many :bitstreams_items
  has_many :bitstreams, through: :bitstreams_items
  has_many :communities_items
  has_many :communities, through: :communities_items
end

class Bitstream < ActiveRecord::Base
  has_many :bitstreams_items
  has_many :items, through: :bitstreams_items
  has_many :bitstreams_name_strings
  has_many :name_strings, through: :bitstreams_name_strings
  
  def path
    dir = File.join(HpsBioindex.conf.harvest_dir,
              internal_id[0..1],
              internal_id[2..3],
              internal_id)
    FileUtils.mkdir_p(dir) unless File.exist?(dir) 
    File.join(dir, file_name)
  end

  def names_info
    ids = Bitstream.connection.select_values("
      select ns.id 
      from name_strings ns 
        join bitstreams_name_strings bns 
          on bns.name_string_id = ns.id 
        join bitstreams bs 
          on bs.id = bns.bitstream_id 
      where bs.id = %s" % self.id).uniq.sort.join(',')
    return [] if ids == '' 
    Bitstream.connection.select("
      select ns.id, rns.id as resolved_name_string_id, 
             cf.id as canonial_form_id, ns.name, ns.resolved, 
             ns.expanded_abbr, rns.in_curated_sources, 
             rns.data_sources_num, ol.url,
             bns.pos_start, bns.pos_end
      from name_strings ns 
        left outer join resolved_name_strings rns 
          on rns.name_string_id = ns.id 
        left outer join canonical_forms cf 
          on cf.id = rns.canonical_form_id 
        left outer join outlinks ol  
          on rns.id = ol.resolved_name_string_id 
        join bitstreams_name_strings bns
          on bns.name_string_id = ns.id
      where ns.id in (%s) and bns.bitstream_id = %s
      order by ns.id" % [ids, self.id])
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

class Outlink < ActiveRecord::Base
  belongs_to :resolved_name_string
end
