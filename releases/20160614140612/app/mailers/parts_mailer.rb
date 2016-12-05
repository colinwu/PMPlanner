class PartsMailer < ApplicationMailer
  smtp_settings[:enable_starttls_auto] = false
  
  def send_order(to, cc, from, subject, msg_body)
    mail(to: to,
         cc: cc,
         from: from,
         subject: subject,
         body: msg_body)
  end
  
end
