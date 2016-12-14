class ChangeVerifiedToEnum < ActiveRecord::Migration[5.0]
  def change
    remove_column :profiles, :verified
    add_column :profiles, :verified, :integer, default: 0
  end
end
