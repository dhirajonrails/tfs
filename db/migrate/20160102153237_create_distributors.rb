class CreateDistributors < ActiveRecord::Migration
  def change
    create_table :distributors do |t|

      t.belongs_to :user
      t.timestamps null: false
    end
  end
end

