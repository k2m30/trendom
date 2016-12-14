class ChangeProfileAgain < ActiveRecord::Migration
  def change
    change_column_default :profiles, :emails, [].to_yaml
  end
end
