class AddShowFieldToCanonicalForms < ActiveRecord::Migration
  def change
      add_column :canonical_forms, :show, :boolean, default: false
      add_index :canonical_forms, :show, name: 'idx_canonical_forms_2'
  end
end
