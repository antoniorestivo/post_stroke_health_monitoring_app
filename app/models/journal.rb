class Journal < ApplicationRecord
  belongs_to :journal_template
  has_one :user, through: :journal_template

  validates :journal_template, presence: true
end