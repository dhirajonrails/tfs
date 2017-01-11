class AddQuickLimitToChangeLimit < ActiveRecord::Migration
  def change
  	add_column :change_limits, :quick_request, :boolean
  end
end
