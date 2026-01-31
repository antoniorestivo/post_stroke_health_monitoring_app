class AddNameToTreatments < ActiveRecord::Migration[8.1]
  def up
    add_column :treatments, :name, :string
  end

  def down
    remove_column :treatments, :name
  end
end
