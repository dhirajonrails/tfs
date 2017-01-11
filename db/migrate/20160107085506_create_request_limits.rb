class CreateRequestLimits < ActiveRecord::Migration
  def change
    create_table :request_limits do |t|
      t.references :requestable, polymorphic: true, index: true
      t.integer :amount
      t.string :bank
      t.string :status
      t.string :tracking_id
      t.boolean :quick_request
      t.string :remark
      t.timestamps null: false
    end
  end
end
