class AddWarningToMetrics < ActiveRecord::Migration[6.0]
  def change
    add_column :health_metrics, :warning_threshold, :float
  end
end
