# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def password_reset
    @user = params[:user]
    @signed_id = @user.generate_token_for(:password_reset)

    mail(to: @user.email, subject: "Reset your password")
  end

  def email_verification
    @user = params[:user]
    @signed_id = @user.generate_token_for(:email_verification)

    mail(to: @user.email, subject: "Verify your email")
  end

  def passwordless
    @user = params[:user]
    @signed_id = @user.sign_in_tokens.create.signed_id(expires_in: 1.day)

    mail(to: @user.email, subject: "✨ Your magic sign in link to Moirée")
  end

  def critic_invitation_instructions
    @user = params[:user]
    @inviting_user = params[:inviting_user]
    @signed_id = @user.sign_in_tokens.create.signed_id(expires_in: 1.day)

    mail(to: @user.email, subject: "You've been invited to rate films on Moirée by #{@inviting_user.name}")
  end

  def invitation_instructions
    @user = params[:user]
    @signed_id = @user.generate_token_for(:password_reset)

    mail(to: @user.email, subject: "You've been invited to be an admin on Moirée")
  end
end
