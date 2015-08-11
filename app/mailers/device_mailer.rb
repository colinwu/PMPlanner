class DeviceMailer < ApplicationMailer
  smtp_settings[:enable_starttls_auto] = false
  
  def send_transfer_request(to, cc, from, subject, msg, from_region, dev_list)
    @dev_list = dev_list
    @msg = msg
    @from_region = from_region
    mail(to: to,
         cc: cc,
         from: from,
         subject: subject,
         )
  end
end
