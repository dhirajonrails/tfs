class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  attr_accessor :login
  has_one :merchant
  has_one :distributor
  has_one :admin
  validates :mobile, length: { is: 10 }, presence: true, uniqueness: true
  accepts_nested_attributes_for :merchant
  accepts_nested_attributes_for :distributor
  accepts_nested_attributes_for :admin

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where(["lower(mobile) = :value OR lower(email) = :value", { :value => login.downcase }]).first
    else
      if conditions[:mobile].nil?
        where(conditions).first
      else
        where(mobile: conditions[:mobile]).first
      end
    end
  end 

  def save_with_merchant
    self.add_role('merchant')
    self.merchant.quick_limit = 0
    self.merchant.balance_limit = 100000
    self.status = 'active'
    self.password = "#{self.mobile.first(4)}@#{Time.now.getlocal.strftime("%d%m")}"
    save(validate:false)
  end

  def save_with_distributor
    self.add_role('distributor')
    self.distributor.balance_limit = 0
    self.status = 'active'
    self.password = "#{self.mobile.first(4)}@#{Time.now.getlocal.strftime("%d%m")}"
    save(validate:false)
  end

  def active_for_authentication?
    super && status != 'inactive'
  end

  def inactive_message
    if status != 'active'
      'Your Account has been Deactivated'
    else
      super
    end
  end  
end
