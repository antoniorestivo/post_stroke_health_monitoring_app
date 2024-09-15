class User < ApplicationRecord
  has_secure_password
  has_many :conditions
  has_one :journal_template
  has_many :journals, through: :journal_template
  has_many :user_charts
  has_many :health_metrics, through: :journal_template
  has_many :treatments, through: :conditions
  has_many :user_logins, dependent: :destroy
  has_one_attached :profile_image

  validates :email, presence: true, uniqueness: true

  def journals
    journal_template&.journals
  end
end
