# frozen_string_literal: true

class Admin
  class FilmsController < AdminController
    before_action :set_festival_and_edition, only: [:index, :new, :create, :csv, :import]
    # before_action :set_film, only: [:show, :edit, :update, :destroy]

    def new
      @film = Film.new
      @film.categorizations.build
      @film.selections.build(edition: @edition)
    end

    def create
      # Check for category with value -1 (new category) and remove from params
      sanitized_params = film_params.delete_if do |k, v|
        k == "categorizations_attributes" && v["0"]["category_id"] == "-1"
      end

      # Flatten countries into a string
      @film = @edition.films.build(sanitized_params)
      @film.country = params[:film][:country].join(",") if params[:film][:country].present?

      # Create new category if present in params
      if params[:new_category].present?
        new_category = Category.find_or_initialize_by(name: params[:new_category], edition: @edition)
        @film.categories << new_category
      end

      # Save film and new category in a transaction
      ActiveRecord::Base.transaction do
        new_category.save! if new_category&.new_record?
        @film.save!
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
                partial: "admin/films/import_result",
                locals: { import_result: import_result },
              ),
              turbo_stream.update(
                helpers.dom_id(@edition, :films),
                partial: "admin/films/film",
                collection: @edition.films,
              ),
            ],
          )
        end
      end
    end

    def add_country
      respond_to do |format|
        format.turbo_stream do
          render(turbo_stream: turbo_stream.append("film-countries", partial: "admin/films/country_select"))
        end
      end
    end

    def remove_country
      respond_to do |format|
        format.turbo_stream do
          render(turbo_stream: turbo_stream.remove(params[:country_select_id]))
        end
      end
    end

    private

    def film_params
      params.require(:film).permit(
        :title,
        :original_title,
        :director,
        :year,
        country: [],
        categorizations_attributes: [
          :category_id,
        ],
      )
    end

    def set_festival_and_edition
      @festival = Festival.find(params[:festival_id])
      @edition = @festival.editions.find(params[:edition_id])
    end
  end
end
