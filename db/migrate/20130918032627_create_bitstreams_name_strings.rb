class CreateBitstreamsNameStrings < ActiveRecord::Migration
  def up
    create_table :bitstreams_name_strings do |t|
      t.references :bitstream
      t.references :name_string
      t.string :verbatim_name
      t.integer :pos_start 
      t.integer :pos_end
      t.timestamps
      t.index :bitstream_id, name: 'idx_bitstream_name_strings_1'
      t.index :name_string_id, name: 'idx_bitstream_name_strings_2'
    end
  end
  
end
