require 'csv'
class Transaction < ActiveRecord::Base
  belongs_to :sender, :foreign_key => :sender_mobile, :primary_key => "mobile"
  belongs_to :beneficiary, :foreign_key => :beneficiary_account_number, :primary_key => "account_number"
  belongs_to :merchant, :foreign_key => :merchant_mobile, :primary_key => "mobile"
  belongs_to :distributor, :foreign_key => :distributor_mobile, :primary_key => "mobile"
  belongs_to :admin, :foreign_key => :admin_mobile, :primary_key => "mobile"
  has_many :change_limits, as: :changable
  STATUS = { 'Done' => 'DONE', 'Delete Transaction' => 'DELETE TRANSACTION', 'REJECT/RETURN' => 'REJECT/RETURN', 'In Process' => 'IN PROCESS' }.with_indifferent_access
  has_many :notifications
  validates :amount, :numericality => { greater_than_or_equal_to: 500, less_than_or_equal_to: 25000 }

  validate :monthly_limit

  def monthly_limit
    unless limit_month
      self.errors.add(:beneficiary, "Monthly Limit crossed")
    end
  end

  # after_create_commit { MessageBroadcastJob.perform_later(self) }

  def limit_month
    amount = self.beneficiary.transactions.where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month).sum(:amount)
    if amount <= 25000
      true
    else
      false
    end
  end

  def self.quick_request amount
    case amount
      when 500..1000 then 7
      when 1001..2500 then 10
      when 2501..4000 then 15
      when 4001..6000 then 20
      when 6001..8000 then 25
      when 8001..10000 then 35
      when 10001..11000 then 38
      when 11001..12000 then 41
      when 12001..13000 then 44
      when 13001..14000 then 47
      when 14001..15000 then 50
      when 15001..16000 then 53
      when 16001..17000 then 56
      when 17001..18000 then 59
      when 18001..19000 then 62
      when 19001..20000 then 65
      when 20001..21000 then 68
      when 21001..22000 then 71
      when 22001..23000 then 74
      when 23001..24000 then 77
      when 24001..25000 then 80
      else 0
    end
  end

  def self.normal_request amount
    case amount
      when 500..1000 then 5
      when 1001..2000 then 6
      when 2001..3000 then 9
      when 3001..4000 then 12
      when 4001..5000 then 15
      when 5001..6000 then 18
      when 6001..7000 then 21
      when 7001..8000 then 24
      when 8001..10000 then 27
      when 10001..11000 then 30
      when 11001..12000 then 33
      when 12001..13000 then 36
      when 13001..14000 then 39
      when 14001..15000 then 42
      when 15001..16000 then 45
      when 16001..17000 then 48
      when 17001..20000 then 50
      when 20001..21000 then 53
      when 21001..22000 then 56
      when 22001..23000 then 59
      when 23001..24000 then 62
      when 24001..25000 then 65
      else 0
    end
  end

  # def self.to_normal_csv(transactions, options = {})
  #   CSV.generate(options) do |csv|
  #     csv << ['NEFT', 'AMOUNT', 'DATE', 'BEN NAME', 'A/C NO', 'SENDER A/C', 'REMARK', 'IFSC CODE', 'A/C TYPE']
  #     transactions.each do |trans|
  #       ben = trans.beneficiary
  #       csv << ['N', trans.amount, trans.created_at.strftime("%d-%m-%Y"), ben.name, ben.account_number, '915020047894209', trans.admin_remark, ben.ifsc_code, '11' ]
  #     end
  #   end
  # end

  def self.to_quick_csv(transactions, options = {})
    CSV.generate(options) do |csv|
      csv << ['Payment Identifier', 'Payment Amount', 'BENEFICIARY NAME', 'BENEFICIARY Account No', 'Debit Account No', 'IFSC CODE', 'A/C TYPE']
      transactions.each do |trans|
        ben = trans.beneficiary
        csv << ['IMPS', trans.amount, ben.name, ben.account_number, '915020047536327', ben.ifsc_code, '11' ]
      end
    end
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end

  def self.to_normal_csv(results, options ={})
    CSV.generate(options) do |csv|
      csv << ['TxnId', 'A/C No']
      results.each do |r|
        csv << [r.txt_id, r.beneficiary_account_number ]
      end
    end
  end
end
