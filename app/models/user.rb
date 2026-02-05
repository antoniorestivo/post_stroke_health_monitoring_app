class User < ApplicationRecord
  has_secure_password

  has_many :conditions, dependent: :destroy
  has_one :journal_template, dependent: :destroy
  has_many :journals, through: :journal_template, dependent: :destroy
  has_many :user_charts, dependent: :destroy
  has_many :health_metrics, through: :journal_template, dependent: :destroy
  has_many :treatments, through: :conditions, dependent: :destroy
  has_many :user_logins, dependent: :destroy
  has_one_attached :profile_image

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 12 }, allow_nil: true

  before_create :generate_confirmation_token
  after_commit :send_confirmation_email, on: :create

  def generate_confirmation_token
    self.confirmation_token ||= SecureRandom.urlsafe_base64(32)
  end

  def send_confirmation_email
    return if self.demo == true || self.email_confirmed == true
    UserMailer.confirmation_email(self).deliver_later
  end

  def confirm_email!(token)
    return false unless token.present? && confirmation_token.present?
    return false unless ActiveSupport::SecurityUtils.secure_compare(token.to_s, confirmation_token.to_s)

    self.email_confirmed = true if respond_to?(:email_confirmed)
    self.confirmation_token = nil
    self.confirmed_at = Time.current if respond_to?(:confirmed_at)
    save!
  end

  def journal_template!
    self.journal_template || raise(ActiveRecord::RecordNotFound)
  end
end