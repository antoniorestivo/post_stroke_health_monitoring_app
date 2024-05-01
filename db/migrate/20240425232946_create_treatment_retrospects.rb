class CreateTreatmentRetrospects < ActiveRecord::Migration[6.0]
  def change
    create_table :treatment_retrospects do |t|
      t.bigint :treatment_id
      t.integer :rating
      t.text :feedback
      t.timestamps
    end
    add_foreign_key :treatment_retrospects, :treatments
  end
end
