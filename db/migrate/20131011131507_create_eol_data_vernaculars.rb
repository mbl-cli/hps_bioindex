class CreateEolDataVernaculars < ActiveRecord::Migration

  def change
    create_table :eol_data_vernaculars do |t|
      t.references :eol_data
      t.index :eol_data_id, name: 'eol_data_synonyms_1'
      t.string :name
      t.string :language

      t.timestamps
    end
  end

end
