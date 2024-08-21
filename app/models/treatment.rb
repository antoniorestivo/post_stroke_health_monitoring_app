class Treatment < ApplicationRecord
  belongs_to :condition
  has_one :user, through: :condition
end
