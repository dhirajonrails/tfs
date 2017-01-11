class AddQuickLimitToMerchant < ActiveRecord::Migration
  def change
  	add_column :merchants, :quick_limit, :integer
  end
end
