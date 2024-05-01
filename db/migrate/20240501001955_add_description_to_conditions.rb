class AddDescriptionToConditions < ActiveRecord::Migration[6.0]
  def change
    add_column :conditions, :description, :text
  end
end
