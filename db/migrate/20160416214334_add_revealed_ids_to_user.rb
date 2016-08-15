class AddRevealedIdsToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :revealed_ids, :text, default: [].to_yaml
  end
end
