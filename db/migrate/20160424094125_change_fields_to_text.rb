class ChangeFieldsToText < ActiveRecord::Migration
  def change
    remove_column :users, :revealed_ids, :text
    add_column :users, :revealed_ids, :text, array: true, default: []
  end
end
