# frozen_string_literal: true

module Sessions
  class PasswordlessesController < ApplicationController
    include LiteFS

    before_action :set_user, only: :edit

    layout "sessions", only: [:new, :edit]

    def new
    end

    def edit
      # Since this is a GET request with write side-effects,
      # we need to ensure that the request is run on the primary instance since we're running LiteFS in production.
      # https://fly.io/docs/litefs/primary/
      # https://fly.io/docs/networking/dynamic-request-routing/#the-fly-replay-response-header

      if (primary_instance_id = litefs_primary_instance_id)
        response.headers["fly-replay"] = "instance=#{primary_instance_id}"
        head(:ok)
      else
        start_new_session_for(@user)

        revoke_tokens

        # This should take the Critic to the Festival listing
        redirect_to(admin_root_path, notice: "Signed in successfully")
      end
    end

    def create
      if (@user = User.find_by(email: params[:email], verified: true))
        send_passwordless_email
        redirect_to(root_path, notice: "Check your email for sign in instructions")
      else
        redirect_to(magic_path, alert: "You can't sign in until you verify your email")
      end
    end

    private

    def set_user
      token = SignInToken.find_signed!(CGI.unescape(params[:sid]))
      @user = token.user
    rescue StandardError
      redirect_to(new_sessions_passwordless_path, alert: "That sign in link is invalid")
    end

    def send_passwordless_email
      UserMailer.with(user: @user).passwordless.deliver_later
    end

    def revoke_tokens
      @user.sign_in_tokens.delete_all
    end
  end
end
