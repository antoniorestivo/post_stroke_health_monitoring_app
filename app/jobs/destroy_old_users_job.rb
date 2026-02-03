class DestroyOldUsersJob < ApplicationJob
  def perform
    User.where("created_at < ?", 48.hours.ago).find_each(&:destroy)
  end
end
