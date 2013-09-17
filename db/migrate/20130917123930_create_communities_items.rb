class CreateCommunitiesItems < ActiveRecord::Migration
  def change
    create_table :communities_items do |t|
      t.references :community
      t.references :item
      t.index :community_id, :name => 'idx_communities_items_1'
      t.index :item_id, :name => 'idx_communities_items_2'
    end
  end
end
