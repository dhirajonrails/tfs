class AddLimitToUser < ActiveRecord::Migration
  def change
  	add_column :users, :balance_limit, :integer
  	add_column :users, :quick_limit, :integer
  end
end
