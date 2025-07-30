# app/helpers/application_helper.rb
module ApplicationHelper
  def status_badge_class(status)
    case status.to_s
    when 'pending'
      'bg-warning text-dark'
    when 'processing'
      'bg-info text-white'
    when 'success'
      'bg-success text-white'
    when 'failed'
      'bg-danger text-white'
    when 'refunded'
      'bg-secondary text-white'
    else
      'bg-light text-dark'
    end
  end
  
  def order_status_icon(status)
    case status.to_s
    when 'pending'
      'fas fa-clock'
    when 'processing'
      'fas fa-spinner fa-spin'
    when 'success'
      'fas fa-check-circle'
    when 'failed'
      'fas fa-exclamation-triangle'
    when 'refunded'
      'fas fa-undo'
    else
      'fas fa-question-circle'
    end
  end
end