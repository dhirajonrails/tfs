class Beneficiary < ActiveRecord::Base
  belongs_to :bank_detail
  has_many :transactions, :foreign_key => :beneficiary_account_number, :primary_key => "account_number"
  has_many :senders, through: :transactions
  has_many :merchants, through: :transactions
  validates :account_number, presence: true, uniqueness: true
  accepts_nested_attributes_for :transactions
end
