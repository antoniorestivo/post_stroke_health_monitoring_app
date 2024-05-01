class DropColumnsFromConditions < ActiveRecord::Migration[6.0]
  def change
    remove_column :conditions, :treatment_retrospect
    remove_column :conditions, :treatment_plan
  end
end
