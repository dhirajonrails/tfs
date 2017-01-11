class Profile < ActiveRecord::Base
  belongs_to :profileable, polymorphic: true
end
