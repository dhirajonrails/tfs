class AddPreviousAnd < ActiveRecord::Migration
  def change
    add_column :change_limits, :previous_limit, :integer
    add_column :change_limits, :current_limit, :integer
    add_column :merchants, :balance_limit, :integer
    add_column :distributors, :balance_limit, :integer
  end
end
