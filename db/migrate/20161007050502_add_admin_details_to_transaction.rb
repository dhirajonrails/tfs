class AddAdminDetailsToTransaction < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :admin_mobile, :string
  end
end
