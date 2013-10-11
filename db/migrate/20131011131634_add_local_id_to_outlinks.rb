class AddLocalIdToOutlinks < ActiveRecord::Migration
  def change

    change_table :outlinks do |t|
      t.integer :local_id
      t.index :local_id
    end

  end
end
