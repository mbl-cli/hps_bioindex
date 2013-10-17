class CreateMetadata < ActiveRecord::Migration
  def change
    create_table :metadata do |t|
      t.references :item
      t.index :item_id, name: 'idx_metadata_1'
      t.string :element
      t.string :qualifier 
      t.string :schema 
      t.string :value 
      t.text :long_value
      t.timestamps
    end
  end
end
