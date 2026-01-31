class Treatment < ApplicationRecord
  belongs_to :condition
  has_one :user, through: :condition
  has_many :treatment_retrospects, dependent: :destroy

  validates :condition, presence: true
  validates :description, presence: true
  validates :name, presence: true
end