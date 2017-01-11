class AddDistIdToDistributor < ActiveRecord::Migration
  def change
  	add_column :distributors, :dist_id, :string
  end
end
