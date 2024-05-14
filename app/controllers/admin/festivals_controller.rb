# frozen_string_literal: true

class Admin
  class FestivalsController < AdminController
    def index
      @festivals = Festival.all
    end

    def show
      @festival = Festival.find(params[:id])
    end

    def new
      @festival = Festival.new
    end

    def create
      @festival = Festival.new(festival_params)

      if @festival.save
        respond_to do |format|
          format.html { redirect_to(admin_festivals_path, notice: "#{@festival.name} created") }
          format.turbo_stream
        end
      else
        render(:new)
      end
    end

    def edit
      @festival = Festival.friendly.find(params[:id])
    end

    def update
      @festival = Festival.friendly.find(params[:id])

      if @festival.update(festival_params)
        redirect_to(admin_festivals_path, notice: "#{@festival.name} updated")
      else
        render(:edit)
      end
    end

    def destroy
      @festival = Festival.friendly.find(params[:id])
      @festival.destroy

      redirect_to(admin_festivals_path, notice: "#{festival.name} deleted")
    end

    private

    def festival_params
      params.require(:festival).permit(:name, :short_name, :url, :country)
    end
  end
end
