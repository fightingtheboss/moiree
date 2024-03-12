# frozen_string_literal: true

class Admin
  class AdminController < ApplicationController
    private

    def authenticate
      if (session_record = Session.find_by_id(cookies.signed[:session_token])) && session_record.user.admin?
        Current.session = session_record
      else
        redirect_to(sign_in_path)
      end
    end
  end
end
