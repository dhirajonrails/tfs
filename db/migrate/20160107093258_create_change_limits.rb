class CreateChangeLimits < ActiveRecord::Migration
  def change
    create_table :change_limits do |t|
      t.references :changable, polymorphic: true, index: true
      t.integer :amount
      t.string :note
      t.string :action
      t.string :source
      t.timestamps null: false
    end
  end
end
