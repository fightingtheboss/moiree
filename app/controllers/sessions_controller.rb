# frozen_string_literal: true

class SessionsController < ApplicationController
  require_authentication only: :destroy

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> do
    redirect_to(new_session_url, alert: "Try again later.")
  end

  def new
    render(layout: "sessions")
  end

  def create
    if (user = User.authenticate_by(params.permit(:email, :password)))
      start_new_session_for(user)

      if user.critic? && (current_edition = user.critic.editions.current.first)
        redirect_to(admin_festival_edition_path(current_edition.festival, current_edition))
      else
        redirect_to(after_authentication_url)
      end
    else
      redirect_to(sign_in_path(email_hint: params[:email]), alert: "That email or password is incorrect")
    end
  end

  def destroy
    terminate_session
    redirect_to(root_path, notice: "You've been logged out")
  end
end
