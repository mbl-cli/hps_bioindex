class AddTaggedToBitstreams < ActiveRecord::Migration

  def change
    change_table :bitstreams do |t|
      t.boolean :tagged, default: false
      t.index :tagged, name: 'idx_bitstreams_2' 
    end
  end
  
end
