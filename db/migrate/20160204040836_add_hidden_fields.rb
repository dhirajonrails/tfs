class AddHiddenFields < ActiveRecord::Migration
  def change
  	add_column :request_limits, :hidden, :boolean
  	add_column :transactions, :hidden, :boolean
  end
end
