# frozen_string_literal: true

module Identity
  class PasswordResetsController < ApplicationController
    before_action :set_user, only: [:edit, :update]

    layout "sessions", only: [:new, :edit]

    def new
    end

    def edit
    end

    def create
      if (@user = User.find_by(email: params[:email]))
        send_password_reset_email
      end

      redirect_to(root_path, notice: "If an account exists for that email, we've sent password reset instructions")
    end

    def update
      if @user.update(user_params.merge(verified: true))
        redirect_to(sign_in_path, notice: "Your password was reset successfully. Please sign in")
      else
        render(:edit, status: :unprocessable_entity)
      end
    end

    private

    def set_user
      @user = User.find_by_token_for!(:password_reset, params[:sid])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to(new_identity_password_reset_path, alert: "That password reset link is invalid")
    end

    def user_params
      params.permit(:password, :password_confirmation)
    end

    def send_password_reset_email
      UserMailer.with(user: @user).password_reset.deliver_later
    end
  end
end
