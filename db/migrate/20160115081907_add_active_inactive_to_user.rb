class AddActiveInactiveToUser < ActiveRecord::Migration
  def change
  	add_column :users, :status, :string
  end
end
