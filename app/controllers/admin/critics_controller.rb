# frozen_string_literal: true

class Admin
  class CriticsController < AdminController
    before_action :set_critic_and_user

    def edit
    end

    def update
      if @user.update(user_params)
        respond_to do |format|
          format.html { redirect_to(critics_admin_users_path, notice: "#{@user.name} updated") }

          format.turbo_stream do
            flash.now[:notice] = "#{@user.name} updated"

            render(
              turbo_stream: [
                turbo_stream.replace(
                  helpers.dom_id(@critic),
                  partial: "admin/users/critic",
                  locals: { critic: @critic },
                ),
                turbo_stream.prepend("flash", partial: "layouts/flash"),
              ],
            )
          end
        end
      else
        respond_to do |format|
          format.html { render(:edit, status: :unprocessable_entity) }

          format.turbo_stream do
            flash.now[:alert] = @user.errors.full_messages.join(", ")

            render(
              turbo_stream: [
                turbo_stream.update("modal", template: "admin/critics/edit"),
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
        :id,
        :userable_type,
        userable_attributes: [
          :id,
          :first_name,
          :last_name,
          :publication,
          :country,
        ],
      )
    end

    def set_critic_and_user
      @critic = Critic.includes(:user).friendly.find(params[:id])
      @user = @critic.user
    end
  end
end
