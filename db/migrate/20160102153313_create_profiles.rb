class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.references :profileable, polymorphic: true, index: true
      t.string :first_name
      t.string :last_name
      t.string :name_of_business
      t.date :dob
      t.string :address1
      t.string :address2
      t.string :state
      t.string :city
      t.integer :pincode
      t.string :reference_name
      t.timestamps null: false
    end
  end
end
