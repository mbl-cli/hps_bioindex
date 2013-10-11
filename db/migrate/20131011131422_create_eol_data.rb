class CreateEolData < ActiveRecord::Migration

  def change
    create_table :eol_data do |t|
      t.references :outlink_id
      t.references :canonical_form_id
      t.string :image_url
      t.string :thumbnail_url
      t.text   :overview

      t.timestamps
    end
  end

end
