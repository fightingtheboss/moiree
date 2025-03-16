# frozen_string_literal: true

class Admin
  class AdminController < ApplicationController
    include Authentication

    require_authentication

    layout :admin_layout

    private

    def admin_layout
      return "turbo_rails/frame" if turbo_frame_request?

      "admin"
    end
  end
end
