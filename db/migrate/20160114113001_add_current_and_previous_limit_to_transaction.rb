class AddCurrentAndPreviousLimitToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :previous_limit, :integer
    add_column :transactions, :current_limit, :integer
  end
end
