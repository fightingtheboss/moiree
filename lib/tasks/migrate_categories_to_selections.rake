# frozen_string_literal: true

namespace :once do
  desc "Migrate categories to selections"
  task migrate_categories_to_selections: :environment do
    puts "Migrating categories to selections..."
    # Populate reference from categorizations
    Selection.find_each do |selection|
      selection.update_column(:category_id, selection.film.categories.where(edition: selection.edition).first.id)
      print "."
    end
  end
end
