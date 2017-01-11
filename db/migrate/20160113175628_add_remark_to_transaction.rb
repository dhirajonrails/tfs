class AddRemarkToTransaction < ActiveRecord::Migration
  def change
  	add_column :transactions, :admin_remark, :string
  	add_column :transactions, :merchant_remark, :string
  end
end
