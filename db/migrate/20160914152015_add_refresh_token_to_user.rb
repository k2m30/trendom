class AddRefreshTokenToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :refresh_tkn, :string
  end
end
