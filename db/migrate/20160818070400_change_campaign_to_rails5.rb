class ChangeCampaignToRails5 < ActiveRecord::Migration[5.0]
  def change
    remove_column :campaigns, :profiles_ids
    add_column :campaigns, :profiles_ids, :integer, array: true, default: []
  end
end
