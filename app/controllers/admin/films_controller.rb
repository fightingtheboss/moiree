# frozen_string_literal: true

class Admin
  class FilmsController < AdminController
    def search
      @films = Film.search(params[:query], edition_id: params[:edition_id], exclude: params[:exclude_films_in_edition])

      if params[:edition_id].present?
        @edition = Edition.friendly.find(params[:edition_id])
        @festival = @edition.festival
        @selections = @edition.selections.includes(:category, :film).where(film: @films).order("films.title")

        render(
          partial: "admin/selections/search_results",
          locals: { festival: @festival, edition: @edition, selections: @selections },
        )
        return
      end

      render(partial: "admin/films/search_results", locals: { films: @films })
    end

    def search_for_film_to_add_to_edition
      @films = Film.search_excluding_edition(params[:query], params[:edition_id])
      @edition = Edition.friendly.find(params[:edition_id])
      @festival = @edition.festival
      @selection_id = params[:selection_id]

      @tmdb_results = TMDB.search(params[:query], year: params[:year] || @edition.year) if params[:query].present?

      respond_to do |format|
        format.html do
          render(
            partial: "admin/films/new_film_search_results",
            locals: {
              festival: @festival,
              edition: @edition,
              films: @films,
              tmdb_results: @tmdb_results,
              selection_id: @selection_id,
            },
          )
        end

        format.turbo_stream do
          render(
            turbo_stream: turbo_stream.replace(
              "new-film-search-results",
              partial: "admin/films/new_film_search_results",
              locals: {
                festival: @festival,
                edition: @edition,
                films: @films,
                tmdb_results: @tmdb_results,
                selection_id: @selection_id,
              },
            ),
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
  end
end
