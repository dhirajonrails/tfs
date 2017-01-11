class Sender < ActiveRecord::Base
  has_many :transactions, :foreign_key => :sender_mobile, :primary_key => "mobile"
  has_many :beneficiaries, through: :transactions
  has_many :merchants, through: :transactions
  # validates :mobile, length: { is: 10 }, presence: true, uniqueness: true
  ID_PROOF = { 'pan' => 'PAN CARD', 'adhar' => 'ADHAR CARD', 'driving_licence' => 'DRIVING LICENCE', 'vote_id' => 'Vote ID' }.with_indifferent_access
  accepts_nested_attributes_for :beneficiaries
end
