# frozen_string_literal: true

Rails.application.configure do
  MissionControl::Jobs.base_controller_class = "Admin::AdminController"
end
