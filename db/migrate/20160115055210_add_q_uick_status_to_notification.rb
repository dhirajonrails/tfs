class AddQUickStatusToNotification < ActiveRecord::Migration
  def change
  	add_column :notifications, :quick_transfer, :boolean
  end
end
