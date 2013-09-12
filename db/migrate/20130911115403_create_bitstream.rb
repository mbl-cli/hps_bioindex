class CreateBitstream < ActiveRecord::Migration
  def up
    create_table :bitstreams do |t|
      t.string :file_name 
      t.string :mime_type
      t.string :internal_id
      t.boolean :downloadable
      t.timestamps
    end

  end
  
  def down
    drop_table :bitstreams
  end
end
