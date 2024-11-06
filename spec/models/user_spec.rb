require 'rails_helper'

RSpec.describe User do
  subject(:user) { User.new }

  describe '#validations' do
    it 'must have an email and password' do
      expect { user.save }.not_to change(User, :count)
      user.save
      expect(user.errors).to be_present
      user.email = 'joe1234@aol.com'
      expect(user.save).to be false
      user.password = 'unique_password'
      expect(user.save).to be true
    end
  end

  describe '#associations' do
    before do
      user.email = 'joe1234@aol.com'
      user.password = 'unique_password'
      user.save!
    end

    it 'can have associated journals' do
      expect(user.respond_to?(:journals)).to be true
    end

    it 'can have a journal_template' do
      expect(user.respond_to?(:journal_template)).to be true
    end

    it 'can have associated conditions' do
      expect(user.respond_to?(:conditions)).to be true
    end

    it 'can have associated user_charts' do
      expect(user.respond_to?(:user_charts)).to be true
    end

    it 'can have associated health metrics' do
      expect(user.respond_to?(:health_metrics)).to be true
    end

    it 'can have associated treatments' do
      expect(user.respond_to?(:treatments)).to be true
    end

    it 'can have associated user_logins' do
      expect(user.respond_to?(:user_logins)).to be true
    end
  end

  describe '#journals' do
    before do
      user.email = 'joe1234@aol.com'
      user.password = 'unique_password'
      user.save!
    end

    let!(:journal1) { create(:journal, user:) }
    let!(:journal2) { create(:journal, user:) }

    it 'returns associated journals' do
      expect(user.journals).to match_array([journal1, journal2])
    end
  end
end
