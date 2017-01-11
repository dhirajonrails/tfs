class AddBankDetailtoBene < ActiveRecord::Migration
  def change
  	add_column :beneficiaries, :bankname, :string
  	add_column :beneficiaries, :state, :string
  	add_column :beneficiaries, :district, :string
  	add_column :beneficiaries, :city, :string
  	add_column :beneficiaries, :branch, :string
  	add_column :beneficiaries, :address, :string
  end
end
