class AddColumnsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :preferred_name, :string
  end
end
