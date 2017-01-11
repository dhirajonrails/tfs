class AddPinAndContactToBank < ActiveRecord::Migration
  def change
		add_column :bank_details, :pincode, :integer
    add_column :bank_details, :contact, :string  
  end
end
