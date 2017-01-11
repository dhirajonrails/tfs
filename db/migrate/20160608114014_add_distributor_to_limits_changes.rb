class AddDistributorToLimitsChanges < ActiveRecord::Migration
  def change
  	add_column :request_limits, :distributor_mobile, :string
  	add_column :change_limits, :distributor_mobile, :string
  end
end
