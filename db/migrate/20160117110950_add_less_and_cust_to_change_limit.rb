class AddLessAndCustToChangeLimit < ActiveRecord::Migration
  def change
    add_column :request_limits, :cust_id, :string
    add_column :change_limits, :less, :string 
    add_column :change_limits, :cust_id, :string 
    remove_column :request_limits, :read_by_distributor
    remove_column :request_limits, :read_by_admin
  end
end
