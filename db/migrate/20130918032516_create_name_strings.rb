class CreateNameStrings < ActiveRecord::Migration
  def change
    create_table :name_strings do |t|
      t.string :name
      t.boolean :expanded_abbr, default: 0
      t.boolean :resolved, default: 0
      t.timestamps
      t.index :name, name: 'idx_name_strings_1'
    end
  end
end
