# frozen_string_literal: true

class Admin
  class RatingsController < AdminController
    before_action :set_festival_and_edition, only: [:new, :create]
    before_action :set_selection

    def new
      @rating = @selection.build_rating
    end

    def create
      @rating = @selection.build_rating(rating_params)

      if @rating.save
        redirect_to(admin_festival_edition_path(@festival, @edition), notice: "Rating created")
      else
        render(:new)
      end
    end

    private

    def set_festival_and_edition
      @festival = Festival.find(params[:festival_id])
      @edition = @festival.editions.find(params[:edition_id])
    end

    def set_selection
      @selection = @edition.selections.includes(:film).find(params[:selection_id])
    end

    def rating_params
      params.require(:rating).permit(:score, :critic_id)
    end
  end
end
