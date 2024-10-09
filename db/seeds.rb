# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

user = User.create(email: 'joe@aol.com', first_name: 'Joe', last_name: 'Young', password: 'abc123')
journal_template = JournalTemplate.create(user: user)
HealthMetric.create(journal_template: journal_template, metric_name: 'Depression Score', metric_data_type: "integer",
                    metric_unit_name: "scale", warning_threshold: 5)
HealthMetric.create(journal_template: journal_template, metric_name: 'Systolic Blood Pressure', metric_data_type: "string",
                    metric_unit_name: "mm/Hg", warning_threshold: 130)
HealthMetric.create(journal_template: journal_template, metric_name: 'Diastolic Blood Pressure', metric_data_type: "string",
                    metric_unit_name: "mm/Hg", warning_threshold: 100)
HealthMetric.create(journal_template: journal_template, metric_name: 'Weight', metric_data_type: "decimal",
                    metric_unit_name: "pounds (lb)", warning_threshold: 210)

10.times do |x|
  Journal.create(journal_template: journal_template, metrics: {"Weight"=>"196", "Depression score"=>"3",
                                              "systolic blood pressure"=>"115", "diastolic blood pressure"=>"78"},
                 created_at: x.days.ago)
end

condition1 = Condition.create(user: user, name: "Kangaroo flu", support: true, created_at: 10.days.ago)

treatment1 = Treatment.create(condition: condition1, description: "Drink apple cider vinegar twice per day",
                              created_at: 10.days.ago)

10.times do |x|
  TreatmentRetrospect.create(treatment: treatment1, rating: (rand(10) + 1), feedback: 'Meh', created_at: x.days.ago)
end













