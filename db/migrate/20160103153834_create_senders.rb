class CreateSenders < ActiveRecord::Migration
  def change
    create_table :senders do |t|
      t.string :name
      t.string :mobile
      t.string :id_proof
      t.text :address 
      t.timestamps null: false
    end
  end
end
