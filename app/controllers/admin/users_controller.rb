# frozen_string_literal: true

class Admin
  class UsersController < AdminController
    layout "users"

    def index
      @users = User.all
    end

    def critics
      @critics = Critic.includes(:user, :ratings, :edition_attendances).all
    end

    def admins
      @admins = Admin.all
    end

    def destroy
      @user = User.find(params[:id])
      @user.destroy

      redirect_to(admin_users_path, notice: "User deleted")
    end
  end
end
