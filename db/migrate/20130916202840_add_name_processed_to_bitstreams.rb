class AddNameProcessedToBitstreams < ActiveRecord::Migration
  def change
    add_column :bitstreams, :names_processed, :boolean
    add_index :bitstreams, :names_processed, name: 'idx_bitstreams_1'
  end
end
