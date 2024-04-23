class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("hello@moir.ee", "Moirée")
  layout "mailer"
end
