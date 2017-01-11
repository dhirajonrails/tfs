class CreateBeneficiaries < ActiveRecord::Migration
  def change
    create_table :beneficiaries do |t|
      t.string :name
      t.string :account_number
      t.string :ifsc_code
      t.timestamps null: false
      t.belongs_to :bank_detail, index: true
    end
  end
end
