class Journal < ApplicationRecord
  belongs_to :journal_template
  def user
    journal_template.user
  end
end
