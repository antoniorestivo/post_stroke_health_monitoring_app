require 'rails_helper'

RSpec.describe 'Api::Treatments', type: :request do
  let(:user) { create(:user) }
  let(:headers) { auth_headers_for(user) }

  describe 'GET /api/conditions/:condition_id/treatments' do
    let(:condition) { create(:condition, user: user) }
    let!(:treatments) { create_list(:treatment, 3, condition: condition) }

    it 'returns treatments for the condition' do
      get "/api/conditions/#{condition.id}/treatments", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_body['treatments']).to be_an(Array)
      expect(json_body['treatments'].size).to eq(3)
      ids = json_body['treatments'].map { |t| t['id'] }
      expect(ids).to match_array(treatments.map(&:id))
    end

    context 'when condition belongs to another user' do
      let(:other_condition) { create(:condition) }

      it 'returns not found' do
        get "/api/conditions/#{other_condition.id}/treatments", headers: headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when condition does not exist' do
      it 'returns not found' do
        get '/api/conditions/0/treatments', headers: headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /api/treatments/all' do
    let(:condition1) { create(:condition, user: user) }
    let(:condition2) { create(:condition, user: user) }
    let!(:treatments1) { create_list(:treatment, 2, condition: condition1) }
    let!(:treatments2) { create_list(:treatment, 1, condition: condition2) }
    let!(:other_user_treatment) { create(:treatment) }

    it 'returns all treatments for current user grouped by condition' do
      get '/api/treatments/all', headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      collection = json_body['condition_treatments']
      expect(collection).to be_an(Array)

      condition_ids = collection.map { |entry| entry['id'] }
      expect(condition_ids).to match_array([condition1.id, condition2.id])

      entry1 = collection.detect { |e| e['id'] == condition1.id }
      entry2 = collection.detect { |e| e['id'] == condition2.id }

      expect(entry1['treatments'].size).to eq(2)
      expect(entry2['treatments'].size).to eq(1)

      all_ids = collection.flat_map { |e| e['treatments'].map { |t| t['id'] } }
      expect(all_ids).to include(*treatments1.map(&:id), *treatments2.map(&:id))
      expect(all_ids).not_to include(other_user_treatment.id)
    end
  end

  describe 'GET /api/conditions/:condition_id/treatments/:id' do
    let(:condition) { create(:condition, user: user) }
    let(:treatment) { create(:treatment, condition: condition) }

    it 'returns the treatment when owned' do
      get "/api/conditions/#{condition.id}/treatments/#{treatment.id}", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_body['id']).to eq(treatment.id)
    end

    context 'when treatment belongs to another user' do
      let(:other_condition) { create(:condition) }
      let(:other_treatment) { create(:treatment, condition: other_condition) }

      it 'returns not found' do
        get "/api/conditions/#{other_condition.id}/treatments/#{other_treatment.id}", headers: headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when treatment does not exist' do
      it 'returns not found' do
        get "/api/conditions/#{condition.id}/treatments/0", headers: headers, as: :json

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/conditions/:condition_id/treatments' do
    let(:condition) { create(:condition, user: user) }

    let(:valid_params) do
      {
        treatment: {
          description: 'New Treatment',
        }
      }
    end

    it 'creates a treatment with valid params' do
      expect do
        post "/api/conditions/#{condition.id}/treatments", params: valid_params, headers: headers, as: :json
      end.to change(Treatment, :count).by(1)

      expect(response).to have_http_status(:created).or have_http_status(:ok)
      expect(json_body['id']).to eq(Treatment.last.id)
      expect(json_body['condition_id']).to eq(condition.id)
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          treatment: {
            description: ''
          }
        }
      end

      it 'does not create treatment and returns errors' do
        expect do
          post "/api/conditions/#{condition.id}/treatments", params: invalid_params, headers: headers, as: :json
        end.not_to change(Treatment, :count)

        expect(response).to have_http_status(:unprocessable_content)
        expect(json_body['errors']).to be_present
      end
    end

    context 'when condition belongs to another user' do
      let(:other_condition) { create(:condition) }

      it 'does not create and returns not found' do
        expect do
          post "/api/conditions/#{other_condition.id}/treatments", params: valid_params, headers: headers, as: :json
        end.not_to change(Treatment, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'PATCH /api/conditions/:condition_id/treatments/:id' do
    let(:condition) { create(:condition, user: user) }
    let(:treatment) { create(:treatment, condition: condition, description: 'Old description') }

    it 'updates treatment with valid params' do
      patch "/api/conditions/#{condition.id}/treatments/#{treatment.id}",
            params: { treatment: { description: 'Updated Description' } },
            headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      expect(json_body['description']).to eq('Updated Description')
      expect(treatment.reload.description).to eq('Updated Description')
    end

    context 'with invalid params' do
      it 'does not update and returns errors' do
        patch "/api/conditions/#{condition.id}/treatments/#{treatment.id}",
              params: { treatment: { description: '' } },
              headers: headers, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        expect(treatment.reload.description).to eq('Old description')
      end
    end

    context 'when treatment belongs to another user' do
      let(:other_condition) { create(:condition) }
      let(:other_treatment) { create(:treatment, condition: other_condition, description: 'Other') }

      it 'returns not found and does not update' do
        patch "/api/conditions/#{other_condition.id}/treatments/#{other_treatment.id}",
              params: { treatment: { description: 'Hacked description' } },
              headers: headers, as: :json

        expect(response).to have_http_status(:not_found)
        expect(other_treatment.reload.description).to eq('Other')
      end
    end
  end

  describe 'DELETE /api/conditions/:condition_id/treatments/:id' do
    let(:condition) { create(:condition, user: user) }
    let!(:treatment) { create(:treatment, condition: condition) }

    it 'destroys owned treatment' do
      expect do
        delete "/api/conditions/#{condition.id}/treatments/#{treatment.id}", headers: headers, as: :json
      end.to change(Treatment, :count).by(-1)

      expect(response).to have_http_status(:no_content).or have_http_status(:ok)
    end

    context 'when treatment belongs to another user' do
      let(:other_condition) { create(:condition) }
      let!(:other_treatment) { create(:treatment, condition: other_condition) }

      it 'does not destroy and returns not found' do
        expect do
          delete "/api/conditions/#{other_condition.id}/treatments/#{other_treatment.id}", headers: headers, as: :json
        end.not_to change(Treatment, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when treatment does not exist' do
      it 'returns not found' do
        expect do
          delete "/api/conditions/#{condition.id}/treatments/0", headers: headers, as: :json
        end.not_to change(Treatment, :count)

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end