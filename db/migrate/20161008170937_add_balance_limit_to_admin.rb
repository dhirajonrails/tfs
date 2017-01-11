class AddBalanceLimitToAdmin < ActiveRecord::Migration[5.0]
  def change
		add_column :admins, :balance_limit, :integer
  end
end
