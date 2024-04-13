# frozen_string_literal: true

class Admin
  class SelectionsController < AdminController
    before_action :set_festival_and_edition

    def new
      @film = params[:film_id] ? Film.find(params[:film_id]) : Film.new
      @film.categorizations.build
      @selection = @film.selections.build(edition: @edition)
    end

    def create
      @selection = Selection.new(selection_params_without_new_category)
      @selection.edition = @edition
      @film = @selection.film

      unless @film.persisted?
        # Flatten countries into a string
        @film.country = params[:film][:country].join(",") if params[:film][:country].present?
      end

      # Save film and new category in a transaction
      ActiveRecord::Base.transaction do
        # Create new category if present in params
        new_category = new_category_for(edition: @edition)
        @film.categories << new_category if new_category

        @selection.save!
      end

      redirect_to(admin_festival_edition_path(@festival, @edition), notice: "#{@film.title} created")
    rescue ActiveRecord::RecordInvalid
      render(:new)
    end

    def import
      import_result = Film.import(params[:edition][:csv], @edition)

      respond_to do |format|
        format.html do
          redirect_to(
            admin_festival_edition_path(@festival, @edition),
            notice: "Imported #{import_result.imported.size} films",
          )
        end

        format.turbo_stream do
          render(
            turbo_stream: [
              turbo_stream.update(
                "modal",
                partial: "admin/selections/import_result",
                locals: { import_result: import_result },
              ),
              turbo_stream.update(
                helpers.dom_id(@edition, :films),
                partial: "admin/selections/selection",
                collection: @edition.selections.includes(:film),
              ),
            ],
          )
        end
      end
    end

    private

    def selection_params
      params.require(:selection).permit(
        film_attributes: [
          :id,
          :title,
          :original_title,
          :director,
          :year,
          country: [],
          categorizations_attributes: [
            :category_id,
          ],
        ],
      )
    end

    def selection_params_without_new_category
      # Check for category with value -1 (new category) and remove from params
      if params[:selection][:film_attributes][:categorizations_attributes]["0"][:category_id] == "-1"
        params[:selection][:film_attributes].delete(:categorizations_attributes)
      end

      selection_params
    end

    def new_category_for(edition:)
      Category.find_or_initialize_by(name: params[:new_category], edition: edition) if params[:new_category].present?
    end

    def set_festival_and_edition
      @festival = Festival.find(params[:festival_id])
      @edition = @festival.editions.find(params[:edition_id])
    end
  end
end
