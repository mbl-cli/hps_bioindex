class CreateResolvedNameStrings < ActiveRecord::Migration
  def change
    create_table :resolved_name_strings do |t|
      t.references :name_string
      t.references :canonical_form
      t.string :name
      t.integer :data_source_id 
      t.string :data_source
      t.string :current_name 
      t.text :classification
      t.text :ranks
      t.boolean :in_curated_sources
      t.integer :data_sources_num
      t.integer :match_type
      t.timestamps
      t.index :name_string_id, name: 'idx_resolved_name_strings_1'
      t.index :canonical_form_id, name: 'idx_resolved_name_strings_2'
    end
  end
end
