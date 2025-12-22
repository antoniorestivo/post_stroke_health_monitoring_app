class TreatmentRetrospect < ApplicationRecord
  belongs_to :treatment

  validates :rating, presence: true
end
