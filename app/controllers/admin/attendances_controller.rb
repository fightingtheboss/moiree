# frozen_string_literal: true

class Admin
  class AttendancesController < AdminController
    layout "editions"

    before_action :set_festival_and_edition

    def index
      @attendances = @edition.attendances.includes(:critic).order("critics.last_name")
      @attending_critics = @attendances.map(&:critic)
      @remaining_critics = Critic.all.excluding(@attending_critics).order(:last_name)
    end

    def new
      @attendance = @edition.attendances.build
      @critics = Critic.left_outer_joins(:attendances)
        .where.not(attendances: { edition: edition })
        .or(Critic.left_outer_joins(:attendances).where(attendances: { edition: nil }))
        .uniq
        .order(:last_name)
    end

    def create
      @attendance = @edition.attendances.build(attendance_params)

      if @attendance.save
        respond_to do |format|
          format.html do
            redirect_to(
              admin_festival_edition_attendances_path(@festival, @edition),
              notice: "Attendance was successfully created.",
            )
          end

          format.turbo_stream do
            flash.now[:notice] = "Added #{@attendance.critic.name} to #{@edition.code}"

            render(turbo_stream: [
              turbo_stream.prepend("flash", partial: "layouts/flash"),
              turbo_stream.replace(
                helpers.dom_id(@attendance.critic),
                partial: "admin/attendances/critic",
                locals: { critic: @attendance.critic, attendance: @attendance },
              ),
            ])
          end
        end
      else
        respond_to do |format|
          format.html do
            flash.now[:alert] = @attendance.errors.full_messages.join(", ")
            render(:new, status: :unprocessable_entity)
          end

          format.turbo_stream do
            flash.now[:alert] = @attendance.errors.full_messages.join(", ")
            render(
              turbo_stream: [
                turbo_stream.prepend("flash", partial: "layouts/flash"),
              ],
              status: :unprocessable_entity,
            )
          end
        end
      end
    end

    def destroy
      @attendance = Attendance.find(params[:id])
      @attendance.destroy

      respond_to do |format|
        format.html do
          redirect_to(
            admin_festival_edition_attendances_path(@festival, @edition),
            notice: "Attendance was successfully destroyed.",
          )
        end

        format.turbo_stream do
          flash.now[:notice] = "Removed #{@attendance.critic.name} from #{@edition.code}"

          render(turbo_stream: [
            turbo_stream.prepend("flash", partial: "layouts/flash"),
          ])
        end
      end
    end

    private

    def attendance_params
      params.require(:attendance).permit(:critic_id)
    end

    def set_festival_and_edition
      @edition = Edition.includes(:festival).find(params[:edition_id])
      @festival = @edition.festival
    end
  end
end
