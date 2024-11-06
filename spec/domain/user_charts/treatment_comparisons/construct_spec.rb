require 'rails_helper'

RSpec.describe UserCharts::TreatmentComparisons::Construct do
  let(:user) { create(:user) }
  let(:user_chart) { create(:user_chart, user:) }
  let(:treatment_1) { create(:treatment, description: 'Physical Therapy Session', user:) }
  let(:treatment_2) { create(:treatment, description: 'Acupuncture Treatment', user:) }
  let(:retrospect_1) { create(:treatment_retrospect, treatment: treatment_1, rating: 4) }
  let(:retrospect_2) { create(:treatment_retrospect, treatment: treatment_2, rating: 5) }
  let(:retrospects) { [retrospect_1, retrospect_2] }

  let(:construct) { described_class.new(user_chart, retrospects) }

  describe '#shaped_data' do
    it 'returns the correct labels and datasets' do
      shaped_data = construct.shaped_data

      expect(shaped_data[:labels]).to eq(['Physical Therap', 'Acupuncture Tre'])
      expect(shaped_data[:datasets]).to be_an(Array)
      expect(shaped_data[:datasets].first[:label]).to eq('Treatment Rating Comparison')
      expect(shaped_data[:datasets].first[:data]).to eq([[4], [5]])
    end
  end
end
