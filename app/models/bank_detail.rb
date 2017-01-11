class BankDetail < ActiveRecord::Base
  has_many :beneficiaries
end
