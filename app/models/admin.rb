# frozen_string_literal: true

class Admin < ApplicationRecord
  include Userable

  def name
    username&.capitalize || email
  end

  def initials
    username ? username[0].upcase : email.split("@").first[0].upcase
  end
end
