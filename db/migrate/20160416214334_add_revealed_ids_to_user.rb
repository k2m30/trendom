class AddRevealedIdsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :revealed_ids, :text, array: true, default: []
  end
end
