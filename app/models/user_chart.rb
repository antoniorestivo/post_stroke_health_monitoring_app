class UserChart < ApplicationRecord
  belongs_to :user

  def self.create_with_implicit_type(params)
    if params['x_label'] == 'Time'
      chart_type = 'line'
    elsif params['y_label'] == 'Frequency / Count'
      chart_type = 'bar'
    else
      chart_type = 'scatter'
    end
    create(chart_type: chart_type, **params)
  end

  def self.update_with_implicit_type(params)
    if params['x_label'] == 'Time'
      chart_type = 'line'
    elsif params['y_label'] == 'Frequency / Count'
      chart_type = 'bar'
    else
      chart_type = 'scatter'
    end
    update(chart_type: chart_type, **params)
  end
end
