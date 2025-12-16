# frozen_string_literal: true

class ExampleJob < ApplicationJob
  sidekiq_options queue: :default, retry: 5
  def perform(message, user_id = nil)
    Rails.logger.info(
      "[ExampleJob] Processing job " \
      "message=#{message.inspect} user_id=#{user_id.inspect} at=#{Time.current}"
    )
  end
end
