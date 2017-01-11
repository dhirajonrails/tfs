class CreateAdmins < ActiveRecord::Migration[5.0]
  def change
    create_table :admins do |t|
      t.belongs_to :user
      t.string :mobile

      t.timestamps
    end
  end
end
