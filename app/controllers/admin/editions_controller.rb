# frozen_string_literal: true

class Admin
  class EditionsController < AdminController
    layout "editions", only: [:show]

    before_action :set_festival
    before_action :set_edition, only: [:show, :edit, :update, :destroy]

    def new
      @edition = @festival.editions.new
    end

    def create
      @edition = @festival.editions.new(edition_params)

      if @edition.save
        respond_to do |format|
          format.html { redirect_to(admin_festival_editions_path(@festival), notice: "Edition created") }
          format.turbo_stream
        end
      else
        render(:new)
      end
    end

    def show
      @selections = @edition.selections.includes(:category, :film, ratings: :critic).order("films.title")
      @films = @selections.map(&:film)
      render("admin/selections/index")
    end

    def edit
    end

    def update
      if @edition.update(edition_params)
        redirect_to(admin_festival_edition_path(@edition.festival, @edition), notice: "Edition updated")
      else
        render(:edit)
      end
    end

    def destroy
      @edition.destroy

      redirect_to(admin_festivals_path(@edition.festival), notice: "Edition deleted")
    end

    private

    def set_festival
      @festival = Festival.friendly.find(params[:festival_id])
    end

    def edition_params
      params.require(:edition).permit(:code, :year, :start_date, :end_date, :url, :target_collection_id)
    end

    def set_edition
      @edition = Edition.friendly.find(params[:id])
    end
  end
end
