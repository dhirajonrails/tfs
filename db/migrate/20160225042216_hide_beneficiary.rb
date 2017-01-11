class HideBeneficiary < ActiveRecord::Migration
  def change
  	add_column :beneficiaries, :hidden, :boolean
  end
end
