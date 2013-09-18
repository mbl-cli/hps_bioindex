class CreateCanonicalForms < ActiveRecord::Migration
  def change
    create_table :canonical_forms do |t|
      t.string :name
      t.timestamps
      t.index :name, name: 'idx_canonical_forms_1'
    end
  end
end
