class CreateBitstreamItems < ActiveRecord::Migration
  def up
    create_table :bitstreams_items do |t|
      t.references :bitstream
      t.references :item
    end
    add_index :bitstreams_items, :bitstream_id, 
      name: 'idx_bitstreams_items_1' 
    add_index :bitstreams_items, :item_id, 
      name: 'idx_bitstreams_items_2' 
  end
  
  def down
    drop_table :bitstreams_items
  end
end
