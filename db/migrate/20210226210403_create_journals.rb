class CreateJournals < ActiveRecord::Migration[6.0]
  def change
    create_table :journals do |t|
      t.integer :user_id
      t.text :description
      t.string :image_url
      t.string :video_url
      t.text :health_routines
      t.string :bp_avg
      t.text :bp_annotations
      t.string :image_of_tongue

      t.timestamps
    end
  end
end
