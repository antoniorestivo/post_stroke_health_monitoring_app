require 'rails_helper'

RSpec.describe UserCharts::Enrich do
  let(:user_chart) { create(:user_chart, chart_type: 'line', x_label: 'Time', y_label: 'steps', options: { 'treatmentIds' => [1, 2] }) }
  let!(:journal_1) { create(:journal, created_at: 1.day.ago, metrics: { 'steps' => 1000, 'calories' => 250 }) }
  let!(:journal_2) { create(:journal, created_at: 2.days.ago, metrics: { 'steps' => 2000, 'calories' => 500 }) }
  let(:journals) { Journal.all }
  let(:enricher) { described_class.new(user_chart, journals) }

  describe '#data' do
    context 'when chart_type is boxplot' do
      let(:user_chart) { create(:user_chart, chart_type: 'boxplot', options: { 'treatmentIds' => [treatment1.id, treatment2.id] }) }
      let!(:treatment_retrospect1) { create(:treatment_retrospect, treatment: treatment1) }
      let!(:treatment_retrospect2) { create(:treatment_retrospect, treatment: treatment2) }
      let(:treatment1) { create(:treatment) }
      let(:treatment2) { create(:treatment) }
      let(:retrospects) { TreatmentRetrospect.all }


      before do
        allow(UserCharts::TreatmentComparisons::Construct).to receive(:build)
      end

      it 'handles boxplot data via TreatmentComparisons::Construct' do
        enricher.data
        expect(UserCharts::TreatmentComparisons::Construct).to have_received(:build)
                                                                 .with(user_chart,
                                                                       array_including(treatment_retrospect1, treatment_retrospect2))
      end
    end

    context 'when chart_type is not boxplot' do
      it 'returns the refined data' do
        data = enricher.data

        expect(data[:x]).to eq([journal_1.created_at.strftime('%m-%d-%Y'), journal_2.created_at.strftime('%m-%d-%Y')])
        expect(data[:y]).to eq([1000, 2000])
        expect(data[:thresholds]).to eq({ x: nil, y: nil })
      end
    end
  end
end
