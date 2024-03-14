# frozen_string_literal: true

class Admin
  class FestivalsController < ApplicationController
    def index
      @festivals = Festival.all
    end

    def new
      @festival = Festival.new
    end

    def create
      @festival = Festival.new(festival_params)

      if @festival.save
        redirect_to(admin_festivals_path, notice: "#{@festival.name} created")
      else
        render(:new)
      end
    end

    def edit
      @festival = Festival.find(params[:id])
    end

    def update
      @festival = Festival.find(params[:id])

      if @festival.update(festival_params)
        redirect_to(admin_festivals_path, notice: "#{@festival.name} updated")
      else
        render(:edit)
      end
    end

    def destroy
      @festival = Festival.find(params[:id])
      @festival.destroy

      redirect_to(admin_festivals_path, notice: "#{festival.name} deleted")
    end

    private

    def festival_params
      params.require(:festival).permit(:name, :short_name, :url, :country)
    end
  end
end
