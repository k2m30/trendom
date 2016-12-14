class ChangerOrderNumberToBigNumber < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :order_number
    add_column :users, :order_number, :string
  end
end
