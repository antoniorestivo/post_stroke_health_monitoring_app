# Ensure Psych can load YAML files with aliases enabled for database configuration
db_config_file = Rails.root.join('config', 'database.yml')

database_configuration = YAML.safe_load(
  ERB.new(File.read(db_config_file)).result,
  aliases: true
)

# Use ActiveRecord::Base directly to configure the database
ActiveRecord::Base.configurations = database_configuration
