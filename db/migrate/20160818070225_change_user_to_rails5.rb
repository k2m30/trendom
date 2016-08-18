class ChangeUserToRails5 < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :revealed_ids
    add_column :users, :revealed_ids, :integer, array: true, default: []

    remove_column :users, :campaigns_sent_ids
    add_column :users, :campaigns_sent_ids, :integer, array: true, default: []
  end
end
