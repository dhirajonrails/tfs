class AddDistrictToBankDetail < ActiveRecord::Migration
  def change
  	add_column :bank_details, :district, :string
  end
end
