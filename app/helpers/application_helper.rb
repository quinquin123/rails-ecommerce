module ApplicationHelper
  def status_badge_class(status)
    case status
    when 'success' then 'bg-success'
    when 'failed' then 'bg-danger'
    when 'refunded' then 'bg-warning text-dark'
    else 'bg-secondary'
    end
  end 
end
