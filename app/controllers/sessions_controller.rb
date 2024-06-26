# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:new, :create]

  before_action :set_session, only: :destroy

  layout "sessions", only: [:new]

  def index
    @sessions = Current.user.sessions.order(created_at: :desc)
  end

  def new
  end

  def create
    if (user = User.authenticate_by(email: params[:email], password: params[:password]))
      @session = user.sessions.create!
      cookies.signed.permanent[:session_token] = { value: @session.id, httponly: true }

      redirect_to(root_path, notice: "Signed in successfully")
    else
      redirect_to(sign_in_path(email_hint: params[:email]), alert: "That email or password is incorrect")
    end
  end

  def destroy
    @session.destroy

    redirect_to(root_path, notice: "You've been logged out")
  end

  private

  def set_session
    @session = if params[:id]
      Current.user.sessions.find(params[:id])
    else
      Current.session
    end
  end
end
