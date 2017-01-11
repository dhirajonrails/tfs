class AddStatusToChangeLimit < ActiveRecord::Migration
  def change
  	add_column :change_limits, :status, :string
  end
end
