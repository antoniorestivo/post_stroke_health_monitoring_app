class UserChart < ApplicationRecord
  belongs_to :user
  has_many :health_metrics, through: :user
  has_many :journals, through: :user

  def self.create_with_implicit_type(params)
    if params.dig('options', 'treatmentIds')&.count&.positive?
      chart_type = 'boxplot'
    elsif params['x_label'] == 'Time'
      chart_type = 'line'
    elsif params['y_label'] == 'Frequency / Count'
      chart_type = 'bar'
    else
      chart_type = 'scatter'
    end
    create(chart_type: chart_type, **params)
  end

  def self.update_with_implicit_type(params)
    if params.dig('options', 'treatmentIds')&.count&.positive?
      chart_type = 'boxplot'
    elsif params['x_label'] == 'Time'
      chart_type = 'line'
    elsif params['y_label'] == 'Frequency / Count'
      chart_type = 'bar'
    else
      chart_type = 'scatter'
    end
    update(chart_type: chart_type, **params)
  end

  def self.create_with_mode(params)
    mode = params[:chart_mode]

    chart_type =
      case mode
      when "treatment_comparison" then "boxplot"
      when "metric_over_time"     then "line"
      when "metric_frequency"     then "bar"
      when "metric_vs_metric"     then "scatter"
      else
        raise ArgumentError, "Unknown chart mode"
      end

    create!(chart_type: chart_type, **params)
  end
end
