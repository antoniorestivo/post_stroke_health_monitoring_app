class CreateTreatments < ActiveRecord::Migration[6.0]
  def change
    create_table :treatments do |t|
      t.bigint :condition_id
      t.text :description
      t.timestamps
    end
    add_foreign_key :treatments, :conditions
  end
end
