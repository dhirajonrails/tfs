class AddQuickTranserToTransaction < ActiveRecord::Migration
  def change
  	add_column :transactions, :quick_transfer, :boolean
  end
end
