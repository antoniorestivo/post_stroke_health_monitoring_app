class AddUsageStatisticsToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :usage_statistics, :jsonb
  end
end
