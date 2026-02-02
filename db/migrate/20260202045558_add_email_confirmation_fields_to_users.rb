class AddEmailConfirmationFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :email_confirmed, :boolean, default: false, null: false
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime

    add_index :users, :email, unique: true
    add_index :users, :confirmation_token, unique: true
  end
end
