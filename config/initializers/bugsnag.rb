if Rails.application.credentials.bugsnag.present?
  Bugsnag.configure do |config|
    config.api_key = Rails.application.credentials.bugsnag.api_key
  end
end
