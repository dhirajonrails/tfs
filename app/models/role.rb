class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true

  validates :resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true

  scopify
  STATUS = { 'Done' => 'DONE',
  					 'Delete Transaction' => 'DELETE TRANSACTION',
  					 'REJECT/RETURN' => 'REJECT/RETURN',
  					 'In Process' => 'IN PROCESS' }.with_indifferent_access

end
