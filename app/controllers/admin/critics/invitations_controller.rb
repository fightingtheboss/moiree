# frozen_string_literal: true

class Admin
  module Critics
    class InvitationsController < AdminController
      def new
        @user = User.new(userable: Critic.new)
      end

      def create
        @user = User.create_with(user_params).find_or_initialize_by(email: params[:user][:email])

        if @user.save
          send_passwordless_email
          redirect_to(new_admin_critics_invitation_path, notice: "An invitation email has been sent to #{@user.email}")
        else
          render(:new, status: :unprocessable_entity)
        end
      end

      private

      def user_params
        params.require(:user).permit(
          :email,
          :userable_type,
          userable_attributes: [
            :first_name,
            :last_name,
            :publication,
            :country,
          ],
        ).merge(
          password: SecureRandom.base58,
          verified: true,
        )
      end

      def send_passwordless_email
        UserMailer.with(user: @user).passwordless.deliver_later
      end

      def temporary_username(email)
        email.split("@").first
      end
    end
  end
end
