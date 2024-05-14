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
      @selection = @edition.selections.build(selection_params_without_new_category)

      if params[:film_id].present?
        @film = Film.find(params[:film_id])
        @selection.film = @film
      else
        @film = @selection.film
        @film.country = params[:film][:country].join(",") if params[:film][:country].present?
      end

      # Save film and new category in a transaction
      ActiveRecord::Base.transaction do
        category = category_for(edition: @edition)
        @film.categories << category if category

        @film.save!
        @selection.save!
      end

      respond_to do |format|
        format.html do
          redirect_to(admin_festival_edition_path(@festival, @edition), notice: "#{@film.title} created")
        end

        format.turbo_stream do
          flash.now[:notice] = "#{@film.title} created"
          render(turbo_stream: [
            turbo_stream.prepend("flash", partial: "layouts/flash"),
            turbo_stream.prepend(
              "search-results",
              partial: "admin/selections/selection",
              locals: { festival: @festival, edition: @edition, selection: @selection },
            ),
          ])
        end
      end
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html { render(:new) }
        format.turbo_stream do
          flash.now[:alert] = @rating.errors.full_messages.join(", ")
          render(
            turbo_stream: [
              turbo_stream.update(
                "modal",
                template: "admin/ratings/edit",
                locals: { festival: @festival, edition: @edition, selection: @selection },
              ),
              turbo_stream.prepend("flash", partial: "layouts/flash"),
            ],
            status: :unprocessable_entity,
          )
        end
      end
    end

    def edit
      @selection = Selection.find(params[:id])
      @film = @selection.film
    end

    def update
      @selection = Selection.find(params[:id])
      @film = @selection.film

      @film.country = params[:film][:country].join(",") if params[:film][:country].present?

      ActiveRecord::Base.transaction do
        # Handle new category
        category = category_for(edition: @edition)

        @film.categories << category if category.new_record?

        @selection.update!(selection_params_without_new_category)
      end

      respond_to do |format|
        format.html do
          redirect_to(
            admin_festival_edition_path(@festival, @edition),
            notice: "#{@film.title} updated for #{@edition.code}",
          )
        end

        format.turbo_stream do
          flash.now[:notice] = "#{@film.title} updated for #{@edition.code}"
          render(turbo_stream: [
            turbo_stream.prepend("flash", partial: "layouts/flash"),
            turbo_stream.replace(
              helpers.dom_id(@selection),
              partial: "admin/selections/selection",
              locals: { festival: @festival, edition: @edition, selection: @selection },
            ),
          ])
        end
      end
    rescue ActiveRecord::RecordInvalid
      respond_to do |format|
        format.html { render(:edit) }

        format.turbo_stream do
          flash.now[:alert] = @rating.errors.full_messages.join(", ")
          render(
            turbo_stream: [
              turbo_stream.update(
                "modal",
                template: "admin/ratings/edit",
                locals: { festival: @festival, edition: @edition, selection: @selection },
              ),
              turbo_stream.prepend("flash", partial: "layouts/flash"),
            ],
            status: :unprocessable_entity,
          )
        end
      end
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
        :film_id,
        film_attributes: [
          :id,
          :title,
          :original_title,
          :director,
          :year,
          country: [],
          categorizations_attributes: [
            :category_id,
            :id,
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

    def existing_category_id
      if params[:new_category].blank?
        params[:selection][:film_attributes][:categorizations_attributes]["0"][:category_id]
      end
    end

    def category_for(edition:)
      if params[:new_category].present?
        Category.find_or_initialize_by(name: params[:new_category], edition: edition)
      else
        Category.find_by(id: existing_category_id)
      end
    end

    def set_festival_and_edition
      @edition = Edition.includes(:festival).friendly.find(params[:edition_id])
      @festival = @edition.festival
    end
  end
end
