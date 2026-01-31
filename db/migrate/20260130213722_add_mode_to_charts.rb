class AddModeToCharts < ActiveRecord::Migration[8.1]
  def up
    add_column :user_charts, :chart_mode, :string, null: false, default: 'metric_vs_metric'
  end

  def down
    remove_column :user_charts, :chart_mode
  end
end
