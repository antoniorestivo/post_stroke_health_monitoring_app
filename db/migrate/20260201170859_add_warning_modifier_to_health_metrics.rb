class AddWarningModifierToHealthMetrics < ActiveRecord::Migration[8.1]
  def up
    add_column :health_metrics, :warning_modifier, :string
  end

  def down
    remove_column :health_metrics, :warning_modifier
  end
end
