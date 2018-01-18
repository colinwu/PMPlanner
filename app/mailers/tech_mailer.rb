class TechMailer < ApplicationMailer
  default from: 'PMPlanner <noreply@sharpsec.com>'
  helper ApplicationHelper

  def pm_list(tech)
    @tech = tech
    @now = Date.today
    @dev_list = []
    range = @tech.preference.upcoming_interval*7
    # toggle to show devices for which the current tech is the backup tech
    if @tech.preference.showbackup == true
      search_ar = ["(devices.primary_tech_id = ? or devices.backup_tech_id = ?) and devices.active is true and devices.under_contract is true and devices.do_pm is true and (outstanding_pms.next_pm_date is not NULL and datediff(outstanding_pms.next_pm_date, curdate()) < #{range})",@tech.id, @tech.id]
    else
      search_ar = ["primary_tech_id = ? and active is true and under_contract is true and do_pm is true and (outstanding_pms.next_pm_date is not NULL and datediff(outstanding_pms.next_pm_date, curdate()) < #{range})", @tech.id]
    end
    
    @code_count = {}
    @code_date = {}
    
    @dev_list = Device.joins(:outstanding_pms).where(search_ar).group("devices.id").sort_by{|d| d.pm_date}
    @dev_list.each do |d|
      pm_list = d.outstanding_pms.where("next_pm_date is not NULL and datediff(next_pm_date, curdate()) < #{range}")
      @code_date[d.id] = pm_list.order("next_pm_date ASC").first.next_pm_date
      @code_count[d.id] = pm_list.length
    end
    
    mail(to: @tech.email, subject: "Your Outstanding PM List as of " + @now.to_s(:MdY))

    tech.update_attributes(sent_date: @now)
  end
end
