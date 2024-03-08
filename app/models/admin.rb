# frozen_string_literal: true

class Admin < ApplicationRecord
  include Userable

  def name
    username
  end

  def initials
    username[0]
  end
end
