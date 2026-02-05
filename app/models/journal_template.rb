class JournalTemplate < ApplicationRecord
  belongs_to :user

  has_many :journals, dependent: :destroy
  has_many :health_metrics, dependent: :destroy

  validate :metric_count_within_limit

  MAX_METRICS = 20

  private

  def metric_count_within_limit
    if health_metrics.size > MAX_METRICS
      errors.add(:health_metrics, "exceeds maximum of #{MAX_METRICS}")
    end
  end
end