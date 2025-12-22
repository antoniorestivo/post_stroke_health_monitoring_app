require "rails_helper"

RSpec.describe "Api::TreatmentRetrospects", type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers_for(user) }
  let(:base_url) do
    "/api/conditions/#{condition.id}/treatments/#{treatment.id}"
  end

  let(:condition) { create(:condition, user:) }
  let(:treatment) { create(:treatment, condition:) }

  describe "POST /treatment_retrospects" do
    let(:params) do
      {
        treatment_id: treatment.id,
        rating: 4,
        feedback: "Felt better after two weeks"
      }
    end

    context "when unauthenticated" do
      it "returns 401" do
        post "#{base_url}/treatment_retrospects", params: params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with valid params" do
      it "creates a treatment retrospect" do
        expect do
          post "/#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json
        end.to change(TreatmentRetrospect, :count).by(1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when treatment does not belong to current user" do
      let(:other_user) { create(:user, email: 'other_user@mail.com') }
      let(:base_url) do
        "/api/conditions/#{other_condition.id}/treatments/#{other_treatment.id}"
      end
      let(:other_condition) { create(:condition, user: other_user) }
      let(:other_treatment) { create(:treatment, condition: other_condition) }

      let(:params) do
        {
          treatment_id: other_treatment.id,
          rating: 3,
          feedback: "Not sure if it helped"
        }
      end

      it "does not create a retrospect and returns 404 or 403" do
        expect do
          post "#{base_url}/treatment_retrospects", params: params, headers: headers, as: :json
        end.not_to change(TreatmentRetrospect, :count)

        expect(response).to have_http_status(:not_found).or have_http_status(:forbidden)
      end
    end

    context "with invalid params" do
      let(:base_url) do
        "/api/conditions/#{condition.id}/treatments/0"
      end

      it "returns 404 when treatment does not exist" do
        post "#{base_url}/treatment_retrospects",
             params: {
               treatment_id: 0,
               rating: 4,
               feedback: "Test"
             },
             headers: headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /api/treatment_retrospects/:id" do
    let!(:retrospect) do
      create(
        :treatment_retrospect,
        treatment:,
        rating: 2,
        feedback: "Initial feedback"
      )
    end

    let(:params) do
      {
        rating: 5,
        feedback: "Updated feedback"
      }
    end

    context "when unauthenticated" do
      it "returns 401" do
        patch "#{base_url}/treatment_retrospects/#{retrospect.id}", params: params, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when retrospect belongs to current user" do
      it "updates the retrospect" do
        patch "#{base_url}/treatment_retrospects/#{retrospect.id}", params: params, headers: headers, as: :json

        expect(response).to have_http_status(:ok)
        retrospect.reload
        expect(retrospect.rating).to eq(5)
        expect(retrospect.feedback).to eq("Updated feedback")
      end
    end

    context "when retrospect belongs to another user" do
      let(:other_user) { create(:user) }
      let(:other_condition) { create(:condition, user: other_user) }
      let(:other_treatment) { create(:treatment, condition: other_condition) }
      let!(:other_retrospect) { create(:treatment_retrospect, treatment: other_treatment, rating: 1) }

      it "does not update and returns 422" do
        patch "#{base_url}/treatment_retrospects/#{other_retrospect.id}", params: params, headers: headers, as: :json

        expect(response).to have_http_status(:not_found).or have_http_status(:unprocessable_content)
        other_retrospect.reload
        expect(other_retrospect.rating).to eq(1)
      end
    end

    context "when retrospect does not exist" do
      it "returns 422" do
        patch "#{base_url}/treatment_retrospects/0", params: params, headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe "DELETE /api/treatment_retrospects/:id" do
    let!(:retrospect) { create(:treatment_retrospect, treatment:) }

    context "when unauthenticated" do
      it "returns 401" do
        delete "#{base_url}/treatment_retrospects/#{retrospect.id}", as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "when retrospect belongs to current user" do
      it "deletes the retrospect" do
        expect do
          delete "#{base_url}/treatment_retrospects/#{retrospect.id}", headers:, as: :json
        end.to change(TreatmentRetrospect, :count).by(-1)

        expect(response).to have_http_status(:ok)
      end
    end

    context "when retrospect belongs to another user" do
      let(:other_user) { create(:user) }
      let(:other_condition) { create(:condition, user: other_user) }
      let(:other_treatment) { create(:treatment, condition: other_condition) }
      let!(:other_retrospect) { create(:treatment_retrospect, treatment: other_treatment) }

      it "does not delete and returns 422" do
        expect do
          delete "#{base_url}/treatment_retrospects/#{other_retrospect.id}", headers: headers, as: :json
        end.not_to change(TreatmentRetrospect, :count)

        expect(response).to have_http_status(:not_found).or have_http_status(:unprocessable_content)
      end
    end

    context "when retrospect does not exist" do
      it "returns 422" do
        delete "#{base_url}/treatment_retrospects/0", headers: headers, as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end
end