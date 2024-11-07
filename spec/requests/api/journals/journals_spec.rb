require 'rails_helper'

RSpec.describe 'Journals requests', type: :request do
  let(:user) { create(:user) }
  let!(:journal_template) { create(:journal_template, user: user) }
  let!(:journal) { create(:journal, journal_template: journal_template) }
  let!(:valid_journal_params) do
    {
      description: "New Journal Entry",
      image_url: "http://example.com/image.jpg",
      video_url: "http://example.com/video.mp4",
      health_routines: ["Routine 1", "Routine 2"],
      metrics: { steps: 10000, calories: 500 }
    }
  end
  let(:current_user) { user }
  before { allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user) }

  describe "GET /api/journals" do
    it "returns success and a list of journals" do
      get '/api/journals', params: { limit: 10, offset: 0 }, as: :json
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /api/journals/new" do
    it "returns success and journal template's health metrics" do
      get '/api/journals/new'
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /api/journals/:id" do
    it "returns the journal when authorized" do
      get "/api/journals/#{journal.id}", as: :json
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized if the user is not the journal's owner" do
      another_user = create(:user, email: 'abc@av.com')
      another_journal = create(:journal, journal_template: journal_template, user: another_user)
      get "/api/journals/#{another_journal.id}"
      expect(response).to have_http_status(422)
    end
  end

  describe "POST /api/journals" do
    it "creates a new journal and redirects to index" do
      expect {
        post "/api/journals", params: valid_journal_params, as: :json
      }.to change(Journal, :count).by(1)
      expect(response).to redirect_to(api_journals_path)
    end
  end

  describe "PATCH/PUT /api/journals/:id" do
    it "updates the journal and renders show" do
      patch "/api/journals/#{journal.id}", params: { description: "Updated description" }, as: :json
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized if the user is not the journal's owner" do
      another_user = create(:user, email: 'joe@bbc.com')
      another_template = create(:journal_template, user: another_user)
      another_journal = create(:journal, journal_template: another_template)
      patch "/api/journals/#{another_journal.id}", params: { description: "New description" }, as: :json
      expect(response).to have_http_status(422)
    end
  end

  describe "DELETE /api/journals/:id" do
    it "deletes the journal when authorized" do
      journal_to_delete = create(:journal, journal_template: journal_template, user: user)
      expect {
        delete "/api/journals/#{journal_to_delete.id}"
      }.to change(Journal, :count).by(-1)
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized if the journal does not belong to the current user" do
      another_user = create(:user, email: 'joe@bbc.com')
      another_template = create(:journal_template, user: another_user)
      another_journal = create(:journal, journal_template: another_template)
      delete "/api/journals/#{another_journal.id}"
      expect(response).to have_http_status(422)
    end
  end
end
