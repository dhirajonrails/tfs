class AddUpdateToRequestlimit < ActiveRecord::Migration
  def change
  	add_column :request_limits, :updated, :boolean
  end
end
