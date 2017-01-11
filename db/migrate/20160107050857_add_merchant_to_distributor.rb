class AddMerchantToDistributor < ActiveRecord::Migration
  def change
		add_reference :merchants, :distributor, index: true
  end
end
