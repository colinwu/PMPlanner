class PmListMailer < ApplicationMailer
  smtp_settings[:enable_starttls_auto] = false
  
  def send_pm_list(to, pm_list)
    @pm_list = pm_list
    mail(
      to: to,
      from: "no-reply@sharpsec.com",
      subject: "Your automated PM List"
    )
  end
end
