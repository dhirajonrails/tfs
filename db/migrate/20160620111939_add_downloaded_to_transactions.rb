class AddDownloadedToTransactions < ActiveRecord::Migration
  def change
  	add_column :transactions, :downloaded, :boolean
  end
end
