class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.boolean :read_by_admin
      t.boolean :read_by_distributor
      t.references :transaction, index: true
      t.references :distributor, index: true
      t.timestamps null: false
    end
  end
end
