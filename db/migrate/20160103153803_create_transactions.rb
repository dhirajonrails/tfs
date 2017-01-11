class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
    	t.string :txt_id
    	t.string :status
      t.integer :amount
      t.integer :charges
      t.timestamps null: false
    end
  end
end
