class CreateUserLogins < ActiveRecord::Migration[6.0]
  def change
    create_table :user_logins do |t|
      t.references :user, foreign_key: true
      t.integer :date_dimension_id, index: true
      t.integer :month_dimension_id, index: true
      t.timestamps
    end
  end
end
