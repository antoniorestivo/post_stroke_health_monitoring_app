class JournalTemplate < ApplicationRecord
  belongs_to :user
  has_many :journals
end
