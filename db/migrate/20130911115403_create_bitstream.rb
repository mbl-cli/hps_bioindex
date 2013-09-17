class CreateBitstream < ActiveRecord::Migration

  def change
    create_table :bitstreams do |t|
      t.string :file_name 
      t.string :mime_type
      t.string :internal_id
      t.boolean :name_processed, default: false
      t.timestamps
      t.index :name_processed, name: 'idx_bitstreams_1'
    end
  end

end
