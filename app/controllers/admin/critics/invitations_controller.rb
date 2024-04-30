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
          send_critic_invitation_email

          respond_to do |format|
            format.html do
              redirect_to(
                new_admin_critics_invitation_path,
                notice: "An invitation email has been sent to #{@user.email}",
              )
            end

            format.turbo_stream do
              flash.now[:notice] = "An invitation email has been sent to #{@user.email}"
              render(turbo_stream: [
                turbo_stream.prepend("flash", partial: "layouts/flash"),
                turbo_stream.prepend("users-list", partial: "admin/users/critic", locals: { critic: @user.userable }),
              ])
            end
          end
        else
          respond_to do |format|
            format.html { render(:new, status: :unprocessable_entity) }

            format.turbo_stream do
              flash.now[:alert] = @user.errors.full_messages.join(", ")

              render(
                turbo_stream: [
                  turbo_stream.update("modal", template: "admin/critics/new"),
                  turbo_stream.prepend("flash", partial: "layouts/flash"),
                ],
                status: :unprocessable_entity,
              )
            end
          end
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

      def send_critic_invitation_email
        UserMailer.with(user: @user, inviting_user: Current.user).critic_invitation_instructions.deliver_later
      end

      def temporary_username(email)
        email.split("@").first
      end
    end
  end
end
