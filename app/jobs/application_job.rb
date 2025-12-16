# frozen_string_literal: true

class ApplicationJob
  include Sidekiq::Worker

  sidekiq_options queue: :default,
                  retry: 5,
                  backtrace: true

  def self.perform_later(*args)
    perform_async(*args)
  end
end
