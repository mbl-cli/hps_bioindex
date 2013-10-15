class CreateEolDataSynonyms < ActiveRecord::Migration

  def change
    create_table :eol_data_synonyms do |t|
      t.references :eol_data
      t.index :eol_data_id, name: 'idx_eol_data_synonyms_1'
      t.string :name
      t.string :relationship

      t.timestamps
    end
  end

end
