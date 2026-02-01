class HealthMetric < ApplicationRecord
  belongs_to :journal_template

  validates :warning_modifier, inclusion: %w(lteq gteq), allow_nil: true # less than equal to, greater than equal to
end
