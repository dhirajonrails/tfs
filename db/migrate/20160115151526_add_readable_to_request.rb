class AddReadableToRequest < ActiveRecord::Migration
  def change
    add_column :request_limits, :read_by_admin, :boolean
    add_column :request_limits, :read_by_distributor, :boolean
  end
end
