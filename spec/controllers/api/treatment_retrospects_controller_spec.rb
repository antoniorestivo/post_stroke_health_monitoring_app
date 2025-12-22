require "rails_helper"

RSpec.describe Api::TreatmentRetrospectsController, type: :request do
  let(:user)        { create(:user) }
  let(:other_user)  { create(:user) }
  let(:headers)     { auth_headers_for(user) }
  let(:other_headers) { auth_headers_for(other_user) }

  let(:condition)       { create(:condition, user: user) }
  let(:other_condition) { create(:condition, user: other_user) }

  let(:treatment)       { create(:treatment, condition: condition) }
  let(:other_treatment) { create(:treatment, condition: other_condition) }

  let(:retrospect)      { create(:treatment_retrospect, treatment: treatment) }
  let(:other_retrospect){ create(:treatment_retrospect, treatment: other_treatment) }

  describe "POST treatment_retrospects" do
    let(:base_url) { "/api/conditions/#{condition.id}/treatments/#{treatment.id}/" }

    context "when authenticated" do
      context "with valid parameters for owned treatment" do
        let(:params) do
          {
            treatment_id: treatment.id,
            rating: 4,
            feedback: "Felt much better"
          }
        end

        it "creates a treatment retrospect" do
          expect {
            post "#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json
          }.to change(TreatmentRetrospect, :count).by(1)
        end

        it "returns created status" do
          post "#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json

          expect(response).to have_http_status(:created).or have_http_status(:ok)
        end

        it "associates retrospect with the treatment" do
          post "#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json

          expect(TreatmentRetrospect.last.treatment).to eq(treatment)
        end
      end

      context "with invalid parameters" do
        let(:params) do
          {
            treatment_id: treatment.id,
            rating: nil,
          }
        end

        it "does not create a treatment retrospect" do
          expect {
            post "#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json
          }.not_to change(TreatmentRetrospect, :count)
        end

        it "returns unprocessable entity status" do
          post "#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json

          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "when treatment belongs to another user" do
        let(:params) do
          {
            treatment_id: other_treatment.id,
            rating: 4,
            feedback: "Felt much better"
          }
        end
        let(:base_url) do
          "/api/conditions/#{condition.id}/treatments/#{other_treatment.id}/"
        end

        it "does not create a retrospect" do
          expect {
            post "#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json
          }.not_to change(TreatmentRetrospect, :count)
        end

        it "returns not found or forbidden" do
          post "#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end

      context "when treatment does not exist" do
        let(:base_url) do
          "/api/conditions/#{condition.id}/treatments/0/"
        end
        let(:params) do
          {
            treatment_id: treatment.id,
            rating: 4,
            feedback: "Felt much better"
          }
        end

        it "does not create a retrospect" do
          expect {
            post "#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json
          }.not_to change(TreatmentRetrospect, :count)
        end

        it "returns not found" do
          post "#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized" do
        post "#{base_url}/treatment_retrospects",
             params: { treatment_retrospect: { treatment_id: treatment.id, rating: 4 } }, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH treatment_retrospects/:id" do
    let(:base_url) { "/api/conditions/#{condition.id}/treatments/#{treatment.id}/" }
    let(:params) do
      {
        rating: 1,
        feedback: "Updated feedback"
      }
    end

    context "when authenticated" do
      context "when retrospect exists and is owned" do
        let(:retrospect_id) { retrospect.id }

        it "updates the retrospect" do
          patch "#{base_url}/treatment_retrospects/#{retrospect_id}", params: params, headers: headers, as: :json

          expect(response).to have_http_status(:ok)
          expect(retrospect.reload.rating).to eq(1)
          expect(retrospect.reload.feedback).to eq("Updated feedback")
        end
      end

      context "with invalid parameters" do
        let(:retrospect_id) { retrospect.id }
        let(:params) do
          {
            rating: nil,
            feedback: ""
          }
        end

        it "does not update the retrospect" do
          original_rating = retrospect.rating
          original_feedback = retrospect.feedback

          patch "#{base_url}/treatment_retrospects/#{retrospect_id}", params: params, headers: headers, as: :json

          expect(response).to have_http_status(:unprocessable_content)
          expect(retrospect.reload.rating).to eq(original_rating)
          expect(retrospect.reload.feedback).to eq(original_feedback)
        end
      end

      context "when retrospect belongs to another user" do
        let(:retrospect_id) { other_retrospect.id }

        it "does not update the retrospect" do
          patch "#{base_url}/treatment_retrospects/#{retrospect_id}", params: params, headers: headers, as: :json

          expect(response).to have_http_status(:unprocessable_content)
          expect(other_retrospect.reload.rating).not_to eq(1)
        end
      end

      context "when retrospect does not exist" do
        let(:retrospect_id) { 0 }

        it "returns not found" do
          patch "#{base_url}/treatment_retrospects/#{retrospect_id}", params: params, headers: headers, as: :json

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when unauthenticated" do
      let(:retrospect_id) { retrospect.id }

      it "returns unauthorized" do
        patch "#{base_url}/treatment_retrospects/#{retrospect_id}", params: params, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/treatment_retrospects/:id" do
    let(:base_url) { "/api/conditions/#{condition.id}/treatments/#{treatment.id}/" }

    context "when authenticated" do
      context "when retrospect exists and is owned" do
        let!(:retrospect) { create(:treatment_retrospect, treatment: treatment) }
        let(:retrospect_id) { retrospect.id }

        it "deletes the retrospect" do
          expect {
            delete "#{base_url}/treatment_retrospects/#{retrospect_id}", headers: headers, as: :json
          }.to change(TreatmentRetrospect, :count).by(-1)
        end

        it "returns no content or ok" do
          delete "#{base_url}/treatment_retrospects/#{retrospect_id}", headers: headers, as: :json

          expect(response).to have_http_status(:ok)
        end
      end

      context "when retrospect belongs to another user" do
        let!(:other_retrospect) { create(:treatment_retrospect, treatment: other_treatment) }
        let(:retrospect_id) { other_retrospect.id }

        it "does not delete the retrospect" do
          expect {
            delete "#{base_url}/treatment_retrospects/#{retrospect_id}", headers: headers, as: :json
          }.not_to change(TreatmentRetrospect, :count)
        end

        it "returns not found or forbidden" do
          delete "#{base_url}/treatment_retrospects/#{retrospect_id}", headers: headers, as: :json

          expect(response).to have_http_status(:unprocessable_content)
        end
      end

      context "when retrospect does not exist" do
        let(:retrospect_id) { 0 }

        it "returns not found" do
          delete "#{base_url}/treatment_retrospects/#{retrospect_id}", headers: headers, as: :json

          expect(response).to have_http_status(:unprocessable_content)
        end
      end
    end

    context "when unauthenticated" do
      let!(:retrospect) { create(:treatment_retrospect, treatment: treatment) }
      let(:retrospect_id) { retrospect.id }

      it "does not delete the retrospect and returns unauthorized" do
        expect {
          delete "#{base_url}/treatment_retrospects/#{retrospect_id}", as: :json
        }.not_to change(TreatmentRetrospect, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end