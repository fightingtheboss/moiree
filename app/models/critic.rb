class Critic < ApplicationRecord
  include Userable

  validates :first_name, :last_name, presence: true

  def name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name.first}#{last_name.first}"
  end
end
