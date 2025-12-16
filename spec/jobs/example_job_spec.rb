# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

RSpec.describe ExampleJob, type: :worker do
  before do
    Sidekiq::Testing.fake!
    ExampleJob.clear
  end

  describe "Sidekiq options" do
    it "includes Sidekiq::Worker" do
      expect(ExampleJob.included_modules).to include(Sidekiq::Worker)
    end

    it "has a queue set" do
      expect(ExampleJob.get_sidekiq_options["queue"]).to be_present
    end
  end

  describe ".perform_async" do
    it "enqueues a job" do
      expect {
        ExampleJob.perform_async("arg1", 123)
      }.to change(ExampleJob.jobs, :size).by(1)

      job = ExampleJob.jobs.last
      expect(job["args"]).to eq(["arg1", 123])
    end
  end

  describe "#perform" do
    it "executes without raising errors" do
      # Adjust expectations to the actual behavior of ExampleJob#perform
      expect { described_class.new.perform("arg1", 123) }.not_to raise_error
    end
  end
end