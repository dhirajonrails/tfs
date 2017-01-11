class AddIndex < ActiveRecord::Migration
  def change
  	add_index(:senders, :mobile)
  	add_index(:beneficiaries, :account_number)
  	add_index(:merchants, :mobile)
  	add_index(:transactions, [:sender_mobile, :txt_id])
  end
end
