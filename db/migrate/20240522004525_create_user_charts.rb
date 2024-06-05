class CreateUserCharts < ActiveRecord::Migration[6.0]
  def change
    create_table :user_charts do |t|
      t.bigint :user_id
      t.string :title
      t.string :chart_type
      t.string :x_label
      t.string :y_label
      t.jsonb :options

      t.timestamps
    end
    add_foreign_key :user_charts, :users
  end
end
