require 'rails_helper'

RSpec.describe Api::JournalsController, type: :controller do
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

  describe "GET #index" do
    it "returns success and a list of journals" do
      get :index, params: { limit: 10, offset: 0 }
      expect(response).to have_http_status(:success)
      expect(assigns(:journals)).not_to be_nil
      expect(assigns(:enriched_metrics)).not_to be_nil
    end
  end

  describe "GET #new" do
    it "returns success and journal template's health metrics" do
      get :new
      expect(response).to have_http_status(:success)
      expect(assigns(:health_metrics)).not_to be_nil
    end
  end

  describe "GET #show" do
    it "returns the journal when authorized" do
      get :show, params: { id: journal.id }
      expect(response).to have_http_status(:success)
      expect(assigns(:journal)).to eq(journal)
    end

    it "returns unauthorized if the user is not the journal's owner" do
      another_user = create(:user, email: 'abc@av.com')
      another_journal = create(:journal, journal_template: journal_template, user: another_user)
      get :show, params: { id: another_journal.id }
      expect(response).to have_http_status(422)
    end
  end

  describe "POST #create" do
    it "creates a new journal and redirects to index" do
      expect {
        post :create, params: valid_journal_params
      }.to change(Journal, :count).by(1)
      expect(response).to redirect_to(action: :index)
    end
  end

  describe "PATCH/PUT #update" do
    it "updates the journal and renders show" do
      patch :update, params: { id: journal.id, description: "Updated description" }
      expect(response).to have_http_status(:success)
      expect(assigns(:journal).description).to eq("Updated description")
    end

    it "returns unauthorized if the user is not the journal's owner" do
      another_user = create(:user, email: 'joe@bbc.com')
      another_template = create(:journal_template, user: another_user)
      another_journal = create(:journal, journal_template: another_template)
      patch :update, params: { id: another_journal.id, description: "New description" }
      expect(response).to have_http_status(422)
    end
  end

  describe "DELETE #destroy" do
    it "deletes the journal when authorized" do
      journal_to_delete = create(:journal, journal_template: journal_template, user: user)
      expect {
        delete :destroy, params: { id: journal_to_delete.id }
      }.to change(Journal, :count).by(-1)
      expect(response).to have_http_status(:success)
    end

    it "returns unauthorized if the journal does not belong to the current user" do
      another_user = create(:user, email: 'joe@bbc.com')
      another_template = create(:journal_template, user: another_user)
      another_journal = create(:journal, journal_template: another_template)
      delete :destroy, params: { id: another_journal.id }
      expect(response).to have_http_status(422)
    end
  end
end
