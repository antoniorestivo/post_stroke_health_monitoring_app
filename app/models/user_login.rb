class UserLogin < ApplicationRecord
  belongs_to :user

  before_create :calculate_date_dimension_ids

  def calculate_date_dimension_ids
    datetime = Time.zone.now
    self.date_dimension_id = datetime.strftime('%Y%m%d').to_i
    self.month_dimension_id = datetime.strftime('%Y%m').to_i
  end
end
