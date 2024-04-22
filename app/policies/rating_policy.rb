# frozen_string_literal: true

class RatingPolicy < ApplicationPolicy
  def create?
    admin? || critic?
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
