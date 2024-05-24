# frozen_string_literal: true

class Admin::CategoriesController < ApplicationController
  layout "editions"

  before_action :set_festival_and_edition
  before_action :set_category, only: [:reorder, :update]

  def index
    @categories = @edition.categories.order(:position)
  end

  def update
    if @category.update(category_params)
      redirect_to(admin_festival_edition_categories_path(@festival, @edition), notice: "Category updated")
    else
      render(:edit)
    end
  end

  def reorder
    if @category.update(position: params[:position].to_i)
      head(:no_content)
    else
      respond_to do |format|
        format.html do
          redirect_to(admin_festival_edition_categories_path(@festival, @edition), alert: "Category order not updated")
        end

        format.turbo_stream do
          flash.now[:alert] = "Category order not updated"
          render(turbo_stream: [
            turbo_stream.prepend("flash", partial: "layouts/flash"),
          ])
        end
      end
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :position, :edition_id, :standalone)
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def set_festival_and_edition
    @edition = Edition.includes(:festival).friendly.find(params[:edition_id])
    @festival = @edition.festival
  end
end
