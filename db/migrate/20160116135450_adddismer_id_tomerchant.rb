class AdddismerIdTomerchant < ActiveRecord::Migration
  def change
  	add_column :merchants, :dist_id, :string
  end
end
