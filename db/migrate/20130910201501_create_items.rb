class CreateItems < ActiveRecord::Migration

  def up
    create_table :items do |t|
      t.datetime :last_modified
      t.string   :resource
      t.boolean  :harvested, default: false
      t.timestamps
    end

    add_index :items, :last_modified, name: 'idx_items_1' 
  end
  
  def down
    drop_table :items
  end

end
