class AddHandleToItems < ActiveRecord::Migration
  def change
    add_column :items, :handle, :string
  end
end
