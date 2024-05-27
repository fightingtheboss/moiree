# frozen_string_literal: true

class Admin
  class UsersController < AdminController
    layout "users"

    def index
      @users = User.all
    end

    def critics
      @critics = Critic.includes(:user, :ratings, :editions).all
    end

    def admins
      @admins = Admin.all
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy

      respond_to do |format|
        format.html do
          redirect_to(critics_admin_users_path, notice: "#{@user.name} (#{@user.email}) deleted") if @user.critic?
          redirect_to(admins_admin_users_path, notice: "#{@user.name} (#{@user.email}) deleted") if @user.admin?
        end

        format.turbo_stream do
          flash.now[:notice] = "#{@user.name} (#{@user.email}) deleted"

          render(
            turbo_stream: [
              turbo_stream.remove(helpers.dom_id(@user.userable)),
              turbo_stream.prepend("flash", partial: "layouts/flash"),
            ],
          )
        end
      end
    end
  end
end
