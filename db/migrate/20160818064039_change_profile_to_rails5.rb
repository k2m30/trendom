class ChangeProfileToRails5 < ActiveRecord::Migration[5.0]
  def change
    remove_column :profiles, :emails
    add_column :profiles, :emails, :text, array: true, default: []
  end
end
