class AddDistibutorDetailsToTransaction < ActiveRecord::Migration
  def change
    rename_column :distributors, :dist_id, :mobile
    add_column :transactions, :distributor_mobile, :string
  end
end
