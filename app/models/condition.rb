class Condition < ApplicationRecord
  belongs_to :user
  has_many :treatments, dependent: :destroy

  validates :name, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 10_000 }, allow_blank: true
end