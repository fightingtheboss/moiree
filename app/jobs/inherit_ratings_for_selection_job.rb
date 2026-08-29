# frozen_string_literal: true

class InheritRatingsForSelectionJob < ApplicationJob
  queue_as :default

  def perform(selection)
    selection.edition.critics.each do |critic|
      Rating.inherit_for(critic:, selection:)
    end
  end
end
