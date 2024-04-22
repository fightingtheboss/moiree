# frozen_string_literal: true

class Admin
  class AdminController < ApplicationController
    layout "admin"

    private

    def authenticate
      if (session_record = Session.find_by_id(cookies.signed[:session_token]))
        Current.session = session_record
      else
        redirect_to(magic_path)
      end
    end
  end
end
