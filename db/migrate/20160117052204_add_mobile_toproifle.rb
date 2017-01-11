class AddMobileToproifle < ActiveRecord::Migration
  def change
  	add_column :profiles, :mobileno, :string
  end
end
