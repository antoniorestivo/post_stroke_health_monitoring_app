class User < ApplicationRecord
  has_secure_password
  has_many :conditions
  has_one :journal_template

  validates :email, presence: true, uniqueness: true

  def journals
    journal_template&.journals
  end
end
