# frozen_string_literal: true

module Admin::SelectionsHelper
  def tmdb_modify_path(festival, edition, selection_id, tmdb_id)
    if selection_id
      edit_admin_festival_edition_selection_path(festival, edition, selection_id, tmdb_id: tmdb_id)
    else
      new_admin_festival_edition_selection_path(festival, edition, tmdb_id: tmdb_id)
    end
  end
end
