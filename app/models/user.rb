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

  before_create :generate_confirmation_token
  after_commit :send_confirmation_email, on: :create

  def generate_confirmation_token
    self.confirmation_token ||= SecureRandom.urlsafe_base64
  end

  def send_confirmation_email
    UserMailer.confirmation_email(self).deliver_later
  end

  def confirm_email!(token)
    return false unless token.present? && ActiveSupport::SecurityUtils.secure_compare(token, confirmation_token.to_s)

    self.email_confirmed = true
    self.confirmation_token = nil
    self.confirmed_at = Time.current if respond_to?(:confirmed_at)
    save!
  end
end