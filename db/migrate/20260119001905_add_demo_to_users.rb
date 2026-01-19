class AddDemoToUsers < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :demo, :boolean, default: false
  end

  def down
    remove_column :users, :demo
  end
end
