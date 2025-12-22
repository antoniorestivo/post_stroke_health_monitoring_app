class Treatment < ApplicationRecord
  belongs_to :condition
  has_one :user, through: :condition

  validates :condition, presence: true
  validates :description, presence: true
end