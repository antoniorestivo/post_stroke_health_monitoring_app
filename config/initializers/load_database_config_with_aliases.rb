# Ensure Psych can load YAML files with aliases enabled for database configuration
db_config_file = Rails.root.join('config', 'database.yml')

Rails.application.config.database_configuration = YAML.safe_load(
  ERB.new(File.read(db_config_file)).result,
  aliases: true
)
