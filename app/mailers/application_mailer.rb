# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name("hey@moir.ee", "MOIRÉE")
  layout "mailer"

  before_action :attach_moiree_logo!

  private

  def attach_moiree_logo!
    attachments.inline["moiree-logo.png"] = File.read(Rails.root.join("app/assets/images/moiree-logo-160.png"))
  end
end
