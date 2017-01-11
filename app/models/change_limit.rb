class ChangeLimit < ActiveRecord::Base
  belongs_to :changable, polymorphic: true
  STATUS = { 'Done' => 'DONE', 'Approve' => 'APPROVE', 'Transaction' => 'TRANSACTION', 'Delete Transaction' => ' DELETE TRANSACTION'   }.with_indifferent_access
  TYPE = { 0 => 'NORMAL', 1 => 'QUICK'}.with_indifferent_access
end
