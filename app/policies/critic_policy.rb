# frozen_string_literal: true

class CriticPolicy < ApplicationPolicy
  def create?
    admin? || critic?
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
