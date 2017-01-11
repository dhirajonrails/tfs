class RequestLimit < ActiveRecord::Base
  belongs_to :requestable, polymorphic: true

  STATUS = { 'On Hold' => 'ON HOLD', 'Approve' => 'APPROVE', 'Reject' => 'REJECT'}.with_indifferent_access
end
