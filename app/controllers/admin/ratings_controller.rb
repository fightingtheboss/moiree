# frozen_string_literal: true

class Admin
  class RatingsController < AdminController
    before_action :set_festival_and_edition
    before_action :set_selection
    before_action :set_rating, only: [:edit, :update]

    def new
      @rating = @selection.ratings.build
    end

    def create
      @rating = @selection.ratings.build(rating_params)

      if @rating.save
        respond_to do |format|
          format.html { redirect_to(admin_festival_edition_path(@festival, @edition), notice: "Rating created") }
          format.turbo_stream do
            flash.now[:notice] = "#{@rating.critic.name} rated #{@rating.film.title} #{@rating.score} stars"
            render(turbo_stream: [
              turbo_stream.prepend("flash", partial: "layouts/flash"),
              turbo_stream.replace(
                helpers.dom_id(@selection, :rate_button_for),
                partial: "admin/ratings/edit_rating_button",
                locals: { festival: @festival, edition: @edition, selection: @selection, rating: @rating },
              ),
            ])
          end
        end
      else
        respond_to do |format|
          format.html { render(:new) }
          format.turbo_stream do
            flash.now[:alert] = @rating.errors.full_messages.join(", ")
            render(
              turbo_stream: [
                turbo_stream.update(
                  "modal",
                  template: "admin/ratings/new",
                  locals: { festival: @festival, edition: @edition, selection: @selection, rating: @rating },
                ),
                turbo_stream.prepend("flash", partial: "layouts/flash"),
              ],
              status: :unprocessable_entity,
            )
          end
        end
      end
    end

    def edit
    end

    def update
      if @rating.update(rating_params)
        respond_to do |format|
          format.html { redirect_to(admin_festival_edition_path(@festival, @edition), notice: "Rating updated") }
          format.turbo_stream do
            flash.now[:notice] = "#{@rating.critic.name} rated #{@rating.film.title} #{@rating.score} stars"
            render(turbo_stream: [
              turbo_stream.prepend("flash", partial: "layouts/flash"),
              turbo_stream.update(helpers.dom_id(@rating), "Your rating: #{@rating.score}"),
            ])
          end
        end
      else
        respond_to do |format|
          format.html { render(:new) }
          format.turbo_stream do
            flash.now[:alert] = @rating.errors.full_messages.join(", ")
            render(
              turbo_stream: [
                turbo_stream.update(
                  "modal",
                  template: "admin/ratings/new",
                  locals: { festival: @festival, edition: @edition, selection: @selection, rating: @rating },
                ),
                turbo_stream.prepend("flash", partial: "layouts/flash"),
              ],
              status: :unprocessable_entity,
            )
          end
        end
      end
    end

    private

    def set_festival_and_edition
      @edition = Edition.includes(:festival).friendly.find(params[:edition_id])
      @festival = @edition.festival
    end

    def set_selection
      @selection = @edition.selections.includes(:film).find(params[:selection_id])
    end

    def set_rating
      @rating = Rating.find(params[:id])
    end

    def rating_params
      params.require(:rating).permit(:score, :critic_id)
    end
  end
end
