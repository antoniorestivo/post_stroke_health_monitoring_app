require 'rails_helper'

RSpec.describe Journals::EnrichMetrics do
  let(:journal_template) { create(:journal_template) }
  let!(:health_metric_1) { create(:health_metric, journal_template: journal_template, metric_name: 'steps', metric_unit_name: 'steps') }
  let!(:health_metric_2) { create(:health_metric, journal_template: journal_template, metric_name: 'calories', metric_unit_name: 'kcal') }
  let(:journal_1) { create(:journal, journal_template: journal_template, metrics: { 'steps' => 1000, 'calories' => 250 }) }
  let(:journal_2) { create(:journal, journal_template: journal_template, metrics: { 'steps' => 2000 }) }

  let(:journals) { [journal_1, journal_2] }
  let(:enricher) { described_class.new(journals, journal_template) }

  describe '#with_units' do
    it 'enriches the journal metrics with units' do
      enriched_metrics = enricher.with_units

      expect(enriched_metrics[journal_1.id]['steps']).to eq('1000 steps')
      expect(enriched_metrics[journal_1.id]['calories']).to eq('250 kcal')
      expect(enriched_metrics[journal_2.id]['steps']).to eq('2000 steps')
    end

    it 'does not add units for metrics not defined in health metrics' do
      journal_3 = create(:journal, journal_template: journal_template, metrics: { 'unknown_metric' => 50 })
      enriched_metrics = described_class.new([journal_3], journal_template).with_units

      expect(enriched_metrics[journal_3.id]['unknown_metric']).to eq('50 ')
    end
  end
end
