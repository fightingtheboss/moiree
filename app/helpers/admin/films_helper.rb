# frozen_string_literal: true

module Admin::FilmsHelper
  def critic_already_rated?(selection)
    Current.user.userable.is_a?(Critic) && Current.user.userable.selections.include?(selection)
  end
end
