class AddUpdatedBooleanTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :updated, :boolean
    add_column :transactions, :sender_mobile, :string
    add_column :transactions, :beneficiary_account_number, :string
    add_column :transactions, :merchant_mobile, :string
  end
end
