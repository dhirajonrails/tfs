class CreateBankDetails < ActiveRecord::Migration
  def change
    create_table :bank_details do |t|
      t.string :name
      t.string :ifsc_code, primary: true
      t.string :city
      t.string :state
      t.string :branch
      t.string :address
      t.timestamps null: false
    end
    add_index :bank_details, :ifsc_code
  end
end
