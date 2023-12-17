class CreateConditions < ActiveRecord::Migration[6.0]
  def change
    create_table :conditions do |t|
      t.integer :user_id
      t.string :name
      t.boolean :support
      t.text :treatment_retrospect
      t.string :treatment_plan
      t.string :image_url
      t.string :video_url

      t.timestamps
    end
    add_foreign_key :conditions, :users
  end
end
