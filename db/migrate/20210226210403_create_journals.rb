class CreateJournals < ActiveRecord::Migration[6.0]
  def change
    create_table :journals do |t|
      t.bigint :journal_template_id
      t.text :description
      t.string :image_url
      t.string :video_url
      t.text :health_routines
      t.jsonb :metrics
  
      t.timestamps
    end
    add_foreign_key :journals, :journal_templates
  end
end
