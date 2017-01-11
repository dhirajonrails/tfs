class Merchant < ActiveRecord::Base
  has_one :profile, as: :profileable
  has_many :request_limits, as: :requestable
  has_many :change_limits, as: :changable
  belongs_to :distributor
  belongs_to :user
  has_many :transactions, :foreign_key => :merchant_mobile, :primary_key => "mobile"
  has_many :senders, through: :transactions
  has_many :beneficiaries, through: :transactions
  accepts_nested_attributes_for :profile
  validates :balance_limit, :numericality => { :greater_than_or_equal_to => 0, :message => 'Insufficient' }
  validates :quick_limit, :numericality => { :greater_than_or_equal_to => 0, :message => 'Insufficient' }
end
