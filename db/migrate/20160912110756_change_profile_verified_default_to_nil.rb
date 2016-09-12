class ChangeProfileVerifiedDefaultToNil < ActiveRecord::Migration[5.0]
  def change
    remove_column :profiles, :verified
    add_column :profiles, :verified, :boolean, default: nil
  end
end
