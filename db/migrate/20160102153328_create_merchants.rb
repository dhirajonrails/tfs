class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.string :source
      t.belongs_to :user
      t.string :mobile
      t.timestamps null: false

    end
  end
end
