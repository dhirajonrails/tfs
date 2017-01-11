class Admin < ApplicationRecord
  has_one :profile, as: :profileable
  belongs_to :user
  has_many :change_limits, as: :changable
  accepts_nested_attributes_for :profile
  validates :balance_limit, :numericality => { :greater_than_or_equal_to => 0, :message => 'Insufficient' }
  has_many :transactions, foreign_key: :admin_mobile, :primary_key => "mobile"
end
