# app/helpers/application_helper.rb
module ApplicationHelper
  def status_badge_class(status)
    case status.to_s
    when 'pending' then 'bg-info text-white'
    when 'paid' then 'bg-success text-white'
    when 'failed' then 'bg-danger text-white'
    else 'bg-secondary'
    end
  end
  
  def order_status_icon(status)
    case status.to_s
    when 'pending' then 'fas fa-clock'
    when 'paid' then 'fas fa-check-circle'
    when 'failed' then 'fas fa-exclamation-triangle'
    else 'fas fa-question-circle'
    end
  end
end