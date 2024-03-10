class JournalTemplate < ApplicationRecord
  belongs_to :user
  has_many :journals
  has_many :health_metrics
end
