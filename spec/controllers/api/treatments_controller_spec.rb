require 'rails_helper'

RSpec.describe Api::TreatmentsController, type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { auth_headers_for(user) }

  describe 'GET /api/conditions/:condition_id/treatments' do
    let!(:condition) { create(:condition, user: user) }
    let!(:other_condition) { create(:condition) }
    let!(:treatments) { create_list(:treatment, 3, condition: condition) }
    let!(:other_treatments) { create_list(:treatment, 2, condition: other_condition) }

    context 'when user is authenticated' do
      context 'and condition exists and belongs to user' do
        it 'returns 200 and treatments for the condition' do
          get api_condition_treatments_path(condition), headers: auth_headers

          expect(response).to have_http_status(:ok)
          trtments = json_body['treatments']
          expect(trtments.size).to eq(3)
          ids = trtments.map { |t| t['id'] }.sort
          expect(ids).to match_array(treatments.map(&:id))
        end
      end

      context 'and condition exists but belongs to another user' do
        it 'returns 404 and does not expose treatments' do
          get api_condition_treatments_path(other_condition), headers: auth_headers

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'and condition does not exist' do
        it 'returns 404' do
          get api_condition_treatments_path(-1), headers: auth_headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401' do
        get api_condition_treatments_path(condition)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/treatments/all' do
    let!(:condition1) { create(:condition, user: user) }
    let!(:condition2) { create(:condition, user: user) }
    let!(:other_condition) { create(:condition) }

    let!(:treatments1) { create_list(:treatment, 2, condition: condition1) }
    let!(:treatments2) { create_list(:treatment, 1, condition: condition2) }
    let!(:other_treatments) { create_list(:treatment, 3, condition: other_condition) }

    context 'when user is authenticated' do
      it 'returns 200 and all treatments for current_user grouped by condition' do
        get api_treatments_all_path, headers: auth_headers

        expect(response).to have_http_status(:ok)
        condition_treatments = json_body['condition_treatments']

        condition_ids = condition_treatments.map { |c| c['id'] }
        expect(condition_ids).to match_array([condition1.id, condition2.id])

        condition1_hash = condition_treatments.detect { |c| c['id'] == condition1.id }
        condition2_hash = condition_treatments.detect { |c| c['id'] == condition2.id }

        expect(condition1_hash['treatments'].size).to eq(2)
        expect(condition1_hash['treatments'].map { |t| t['id'] }).to match_array(treatments1.map(&:id))

        expect(condition2_hash['treatments'].size).to eq(1)
        expect(condition2_hash['treatments'].map { |t| t['id'] }).to match_array(treatments2.map(&:id))

        all_ids = condition_treatments.flat_map { |c| c['treatments'].map { |t| t['id'] } }
        expect(all_ids).not_to include(*other_treatments.map(&:id))
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401' do
        get api_treatments_all_path

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'GET /api/conditions/:condition_id/treatments/:id' do
    let!(:condition) { create(:condition, user: user) }
    let!(:treatment) { create(:treatment, condition: condition) }
    let!(:other_condition) { create(:condition) }
    let!(:other_treatment) { create(:treatment, condition: other_condition) }

    context 'when user is authenticated' do
      context 'and treatment belongs to current_user condition' do
        it 'returns 200 and treatment' do
          get api_condition_treatment_path(condition, treatment), headers: auth_headers

          expect(response).to have_http_status(:ok)
          body = json_body
          expect(body['id']).to eq(treatment.id)
          expect(body['condition_id']).to eq(condition.id)
        end
      end

      context 'and treatment belongs to another user condition' do
        it 'returns 404' do
          get api_condition_treatment_path(other_condition, other_treatment), headers: auth_headers

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'and treatment does not exist' do
        it 'returns 404' do
          get api_condition_treatment_path(condition, -1), headers: auth_headers

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401' do
        get api_condition_treatment_path(condition, treatment)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'POST /api/conditions/:condition_id/treatments' do
    let!(:condition) { create(:condition, user: user) }
    let!(:other_condition) { create(:condition) }

    let(:valid_params) do
      {
        treatment: attributes_for(:treatment).slice(:description)
      }
    end

    let(:invalid_params) do
      {
        treatment: { description: '' }
      }
    end

    context 'when user is authenticated' do
      context 'and condition belongs to user' do
        context 'with valid params' do
          it 'creates treatment, returns 201 and treatment json' do
            expect do
              post api_condition_treatments_path(condition),
                   params: valid_params,
                   headers: auth_headers, as: :json
            end.to change(Treatment, :count).by(1)

            expect(response).to have_http_status(:created)
            body = json_body
            expect(body['id']).to be_present
            expect(body['condition_id']).to eq(condition.id)
            expect(body['name']).to eq(valid_params[:treatment][:name])
          end
        end

        context 'with invalid params' do
          it 'does not create treatment and returns 422 with errors' do
            expect do
              post api_condition_treatments_path(condition),
                   params: invalid_params,
                   headers: auth_headers, as: :json
            end.not_to change(Treatment, :count)

            expect(response).to have_http_status(:unprocessable_content)
            body = json_body
            expect(body['errors']).to be_present
          end
        end
      end

      context 'and condition belongs to another user' do
        it 'does not create treatment and returns 404' do
          expect do
            post api_condition_treatments_path(other_condition),
                 params: valid_params,
                 headers: auth_headers, as: :json
          end.not_to change(Treatment, :count)

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'and condition does not exist' do
        it 'returns 404' do
          post api_condition_treatments_path(-1),
               params: valid_params,
               headers: auth_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 and does not create treatment' do
        expect do
          post api_condition_treatments_path(condition),
               params: valid_params, as: :json
        end.not_to change(Treatment, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /api/conditions/:condition_id/treatments/:id' do
    let!(:condition) { create(:condition, user: user) }
    let!(:treatment) { create(:treatment, condition: condition, description: 'Old description') }

    let!(:other_condition) { create(:condition) }
    let!(:other_treatment) { create(:treatment, condition: other_condition, description: 'Other description') }

    let(:valid_params) do
      { treatment: { description: 'New description' } }
    end

    let(:invalid_params) do
      { treatment: { description: '' } }
    end

    context 'when user is authenticated' do
      context 'and treatment belongs to current_user condition' do
        context 'with valid params' do
          it 'updates treatment and returns 200' do
            patch api_condition_treatment_path(condition, treatment),
                  params: valid_params,
                  headers: auth_headers, as: :json

            expect(response).to have_http_status(:ok)
            expect(treatment.reload.description).to eq('New description')
            body = json_body
            expect(body['description']).to eq('New description')
          end
        end

        context 'with invalid params' do
          it 'does not update treatment and returns 422 with errors' do
            patch api_condition_treatment_path(condition, treatment),
                  params: invalid_params,
                  headers: auth_headers, as: :json

            expect(response).to have_http_status(:unprocessable_content)
            expect(treatment.reload.description).to eq('Old description')
            body = json_body
            expect(body['errors']).to be_present
          end
        end
      end

      context 'and treatment belongs to another user' do
        it 'does not update and returns 404' do
          patch api_condition_treatment_path(other_condition, other_treatment),
                params: valid_params,
                headers: auth_headers, as: :json

          expect(response).to have_http_status(:not_found)
          expect(other_treatment.reload.description).to eq('Other description')
        end
      end

      context 'and treatment does not exist' do
        it 'returns 404' do
          patch api_condition_treatment_path(condition, -1),
                params: valid_params,
                headers: auth_headers, as: :json

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 and does not update' do
        patch api_condition_treatment_path(condition, treatment),
              params: valid_params, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(treatment.reload.description).to eq('Old description')
      end
    end
  end

  describe 'DELETE /api/conditions/:condition_id/treatments/:id' do
    let!(:condition) { create(:condition, user: user) }
    let!(:treatment) { create(:treatment, condition: condition) }

    let!(:other_condition) { create(:condition) }
    let!(:other_treatment) { create(:treatment, condition: other_condition) }

    context 'when user is authenticated' do
      context 'and treatment belongs to current_user condition' do
        it 'destroys treatment and returns 204 or 200' do
          expect do
            delete api_condition_treatment_path(condition, treatment),
                   headers: auth_headers, as: :json
          end.to change(Treatment, :count).by(-1)

          expect([:no_content, :ok]).to include(response.status.to_sym) rescue nil
          expect(response).to have_http_status(:no_content).or have_http_status(:ok)
        end
      end

      context 'and treatment belongs to another user' do
        it 'does not destroy and returns 404' do
          expect do
            delete api_condition_treatment_path(other_condition, other_treatment),
                   headers: auth_headers, as: :json
          end.not_to change(Treatment, :count)

          expect(response).to have_http_status(:not_found)
        end
      end

      context 'and treatment does not exist' do
        it 'returns 404' do
          expect do
            delete api_condition_treatment_path(condition, -1),
                   headers: auth_headers, as: :json
          end.not_to change(Treatment, :count)

          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when user is not authenticated' do
      it 'returns 401 and does not destroy' do
        expect do
          delete api_condition_treatment_path(condition, treatment), as: :json
        end.not_to change(Treatment, :count)

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end