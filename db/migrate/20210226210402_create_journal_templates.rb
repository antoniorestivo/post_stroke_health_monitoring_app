class CreateJournalTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :journal_templates do |t|
      t.bigint :user_id
      t.timestamps

      
    end
    add_foreign_key :journal_templates, :users
  end
end
