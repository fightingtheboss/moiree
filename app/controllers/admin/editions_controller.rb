# frozen_string_literal: true

class Admin
  class EditionsController < AdminController
    layout "editions", only: [:show]

    before_action :set_festival
    before_action :set_edition, only: [:show, :edit, :update, :destroy]

    def index
      @editions = @festival.editions
    end

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
      @selections = @edition.selections_with_categories
      @films = @selections.map(&:film)
      render("admin/selections/index")
    end

    def edit
    end

    def update
      if @edition.update(edition_params)
        redirect_to(admin_festival_editions_path(@edition.festival), notice: "Edition updated")
      else
        render(:edit)
      end
    end

    def destroy
      @edition.destroy

      redirect_to(admin_festival_editions_path(@edition.festival), notice: "Edition deleted")
    end

    private

    def set_festival
      @festival = Festival.find(params[:festival_id])
    end

    def edition_params
      params.require(:edition).permit(:code, :year, :start_date, :end_date, :url, :target_collection_id)
    end

    def set_edition
      @edition = Edition.find(params[:id])
    end
  end
end
