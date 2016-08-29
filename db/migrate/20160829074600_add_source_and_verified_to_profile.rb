class AddSourceAndVerifiedToProfile < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :source, :integer, default: 0
    add_column :profiles, :verified, :boolean, default: false
  end
end
