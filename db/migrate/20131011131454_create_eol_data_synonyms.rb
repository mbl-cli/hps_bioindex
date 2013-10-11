class CreateEolDataSynonyms < ActiveRecord::Migration

  def change
    create_table :eol_data_synonyms do |t|
      t.references :eol_data
      t.index :eol_data_id
      t.string :name
      t.string :type

      t.timestamps
    end
  end

end
