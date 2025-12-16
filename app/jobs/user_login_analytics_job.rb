# frozen_string_literal: true

class UserLoginAnalyticsJob < ApplicationJob
  sidekiq_options queue: :default, retry: 5

  def perform(user_id, metadata = {})
    user = User.find_by(id: user_id)
    return unless user

    track_login!(user, metadata.with_indifferent_access)
  end

  private

  def track_login!(user, metadata)
    timestamp = Time.zone.now

    LoginEvent.create!(
      user:,
      occurred_at: timestamp,
      ip_address: metadata[:ip_address],
      user_agent: metadata[:user_agent],
      location: metadata[:location],
      device_type: metadata[:device_type],
      platform: metadata[:platform],
      extra_metadata: filtered_metadata(metadata)
    )

    increment_daily_login_counter(user, timestamp.to_date)
  rescue StandardError => e
    Rails.logger.error(
      "[UserLoginAnalyticsJob] Failed to track login " \
      "user_id=#{user.id} error=#{e.class} message=#{e.message}"
    )
    raise
  end

  def filtered_metadata(metadata)
    metadata.except(
      :ip_address,
      :user_agent,
      :location,
      :device_type,
      :platform
    )
  end

  def increment_daily_login_counter(user, date)
    key = "user:#{user.id}:logins:#{date}"
    Redis.current.incr(key)
    Redis.current.expire(key, 90.days.to_i)
  rescue StandardError => e
    Rails.logger.warn(
      "[UserLoginAnalyticsJob] Failed to increment daily counter " \
      "user_id=#{user.id} date=#{date} error=#{e.class} message=#{e.message}"
    )
  end
end