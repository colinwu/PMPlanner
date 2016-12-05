module ApplicationHelper
  def sortable(column, title = nil, search = nil)
    title ||= column.titleize
    css_class = (column == sort_column) ? "current #{sort_direction}" : nil
    direction = (column == sort_column && sort_direction == "asc") ? "desc" : "asc"
    link_to title, {sort: column, direction: direction, search: search}, {:class => css_class}
  end
  
  def pm_status_class(dev)
    range = dev.primary_tech.preference.upcoming_interval * 7
    if (not dev.outstanding_pms.where("next_pm_date < ?", Date.today).empty?)
      'past_due'
    elsif (not dev.outstanding_pms.empty?)
      npd = dev.outstanding_pms.order(:next_pm_date).first.next_pm_date
      if (npd < Date.today + range)
        'in_range'
      elsif (npd < Date.today + range*2)
        'range2'
      end
    elsif not dev.neglected.nil?
      if dev.neglected.next_visit < Date.today
        'past_due'
      elsif dev.neglected.next_visit < Date.today + range
        'in_range'
      elsif dev.neglected.next_visit < Date.today + range * 2
        'range2'
      else
        'all_good'
      end
    else
      'all_good'
    end
  end
  
  def replace_my
    if current_technician and (current_technician.admin? or current_technician.manager?)
      unless session[:tech_id].nil?
        tech = Technician.find(session[:tech_id])
        "#{tech.friendly_name}'s"
      else
        'Regional'
      end
    else
      'My'
    end
  end
  
end
