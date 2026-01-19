class DemoSeedUser
  attr_reader :user

  def self.call(user)
    new(user).seed
  end
  def initialize(user)
    @user = user
  end
  
  def seed
    journal_template = JournalTemplate.find_or_create_by!(
      user_id: user.id
    )

    metrics = [
      {
        metric_name: "Sleep Hours",
        metric_data_type: "number",
        metric_unit_name: "hours",
        warning_threshold: 6
      },
      {
        metric_name: "Energy Level",
        metric_data_type: "number",
        metric_unit_name: "scale_1_5",
        warning_threshold: 2
      },
      {
        metric_name: "Exercise Intensity",
        metric_data_type: "number",
        metric_unit_name: "scale_0_3",
        warning_threshold: 0
      },
      {
        metric_name: "Systolic BP",
        metric_data_type: "number",
        metric_unit_name: "mmHg",
        warning_threshold: 140
      },
      {
        metric_name: "Diastolic BP",
        metric_data_type: "number",
        metric_unit_name: "mmHg",
        warning_threshold: 90
      },
      {
        metric_name: "Weight",
        metric_data_type: "number",
        metric_unit_name: "lbs"
      }
    ]

    metrics.each do |attrs|
      HealthMetric.find_or_create_by!(
        journal_template_id: journal_template.id,
        metric_name: attrs[:metric_name]
      ) do |m|
        m.metric_data_type = attrs[:metric_data_type]
        m.metric_unit_name = attrs[:metric_unit_name]
        m.warning_threshold = attrs[:warning_threshold]
      end
    end

    sleep_condition = Condition.find_or_create_by!(
      user_id: user.id,
      name: "Sleep Quality"
    ) do |c|
      c.description = "Tracking sleep consistency and perceived restfulness to understand how sleep habits affect daily energy."
      c.support = false
    end

    sleep_treatment = Treatment.find_or_create_by!(
      condition_id: sleep_condition.id
    ) do |t|
      t.description = "Maintain a consistent bedtime and reduce screen use after 10pm."
    end

    TreatmentRetrospect.find_or_create_by!(
      treatment_id: sleep_treatment.id
    ) do |tr|
      tr.rating = 7
      tr.feedback = "Consistency matters more than total hours. Energy feels more stable on regular sleep weeks."
    end

    cardio_condition = Condition.find_or_create_by!(
      user_id: user.id,
      name: "Cardiovascular Health"
    ) do |c|
      c.description = "Monitoring blood pressure trends alongside exercise and sleep."
      c.support = false
    end

    cardio_treatment = Treatment.find_or_create_by!(
      condition_id: cardio_condition.id
    ) do |t|
      t.description = "Moderate exercise 3–4 times per week and improved sleep consistency."
    end

    TreatmentRetrospect.find_or_create_by!(
      treatment_id: cardio_treatment.id
    ) do |tr|
      tr.rating = 6
      tr.feedback = "Blood pressure trends downward with consistent exercise, though daily readings still fluctuate."
    end

    journal_data = [
      # Week 1
      [5.5,2,0,138,88,198.4,"Late night, restless"],
      [6.0,2,1,140,90,198.2,"Groggy morning"],
      [5.0,1,0,142,92,198.5,"Poor sleep"],
      [6.5,3,2,136,86,198.0,"Evening workout"],
      [7.0,3,1,134,85,197.8,"Felt okay"],
      [8.0,4,2,130,82,197.5,"Relaxed day"],
      [6.0,2,0,138,88,197.9,"Inconsistent bedtime"],

      # Week 2
      [6.5,3,1,136,86,197.6,"Earlier bedtime"],
      [7.0,4,2,132,84,197.2,"Morning walk"],
      [7.2,4,0,130,82,197.0,"Good focus"],
      [6.8,3,1,134,85,196.9,"Mild fatigue"],
      [7.5,4,2,128,80,196.5,"Best day"],
      [8.0,5,3,126,78,196.2,"Strong workout"],
      [7.0,4,0,130,82,196.4,"Stable mood"],

      # Week 3
      [7.2,4,1,128,80,196.1,"Productive"],
      [7.5,5,2,126,78,195.9,"High energy"],
      [7.0,4,0,128,80,196.0,"Slight dip"],
      [7.8,5,2,124,78,195.7,"Best sleep"],
      [7.0,4,1,126,79,195.6,"Consistent"],
      [8.2,5,3,122,76,195.2,"Excellent"],
      [7.5,4,0,124,78,195.4,"Rested"]
    ]

    start_date = 21.days.ago.to_date

    journal_data.each_with_index do |row, i|
      Journal.create!(
        journal_template_id: journal_template.id,
        created_at: start_date + i.days,
        updated_at: start_date + i.days,
        description: row[6],
        metrics: {
          sleep_hours: row[0],
          energy_level: row[1],
          exercise_intensity: row[2],
          systolic_bp: row[3],
          diastolic_bp: row[4],
          weight: row[5]
        }
      )
    end

    UserChart.find_or_create_by!(
      user_id: user.id,
      title: "Sleep vs Energy Level"
    ) do |c|
      c.chart_type = "scatter"
      c.x_label = "sleep_hours"
      c.y_label = "energy_level"
    end

    UserChart.find_or_create_by!(
      user_id: user.id,
      title: "Blood Pressure Trend"
    ) do |c|
      c.chart_type = "line"
      c.x_label = "Time"
      c.y_label = "systolic_bp"
    end

    UserChart.find_or_create_by!(
      user_id: user.id,
      title: "Weight Trend"
    ) do |c|
      c.chart_type = "line"
      c.x_label = "Time"
      c.y_label = "weight"
    end
  end
end
