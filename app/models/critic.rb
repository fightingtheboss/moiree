class Critic < ApplicationRecord
  include Userable

  def name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name.first}.#{last_name.first}."
  end
end
