class CreateOutlinks < ActiveRecord::Migration
  def change
    create_table :outlinks do |t|
      t.references :resolved_name_string
      t.string :name
      t.string :url
      t.timestamps
      t.index :resolved_name_string_id, name: 'idx_outlinks_1'
    end
  end
end
