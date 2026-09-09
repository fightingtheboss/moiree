# frozen_string_literal: true

class SocialPostPolicy < ApplicationPolicy
  def show?
    admin?
  end
end
