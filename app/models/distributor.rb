class Distributor < ActiveRecord::Base
  belongs_to :user
  has_one :profile, as: :profileable
  has_many :request_limits, as: :requestable
  has_many :change_limits, as: :changable
  accepts_nested_attributes_for :profile, :change_limits
  has_many :merchants
  has_many :notifications
  has_many :transactions, :foreign_key => :distributor_mobile, :primary_key => "mobile"
  validates :balance_limit, :numericality => { :greater_than_or_equal_to => 0, :message => 'Insufficient' }
end
