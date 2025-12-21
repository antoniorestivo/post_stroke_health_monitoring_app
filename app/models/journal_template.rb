class JournalTemplate < ApplicationRecord
  belongs_to :user

  has_many :journals, dependent: :nullify
  has_many :health_metrics, dependent: :destroy
end