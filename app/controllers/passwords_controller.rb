# frozen_string_literal: true

class PasswordsController < ApplicationController
  require_authentication

  before_action :set_user

  def edit
    render(layout: "sessions")
  end

  def update
    if @user.update(user_params)
      redirect_to(root_path, notice: "Your password has been changed")
    else
      render(:edit, status: :unprocessable_entity)
    end
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.permit(:password, :password_confirmation, :password_challenge).with_defaults(password_challenge: "")
  end
end
