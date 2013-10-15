class CreateEolData < ActiveRecord::Migration

  def change
    create_table :eol_data do |t|
      t.references :outlink
      t.index :outlink_id, name: 'idx_eol_data_1'
      t.string :image_url
      t.string :thumbnail_url
      t.text   :overview

      t.timestamps
    end
  end

end
