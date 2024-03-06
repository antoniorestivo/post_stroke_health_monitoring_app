class CreateHealthMetrics < ActiveRecord::Migration[6.0]
  def change
    create_table :health_metrics do |t|
      t.bigint :journal_template_id
      t.string :metric_name
      t.string :metric_data_type
      t.string :metric_unit_name

      t.timestamps
    end
    add_foreign_key :health_metrics, :journal_templates
  end
end
