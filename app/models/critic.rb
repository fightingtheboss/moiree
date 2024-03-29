# frozen_string_literal: true

class Critic < ApplicationRecord
  include Userable

  has_many :ratings, dependent: :destroy
  has_many :selections, through: :ratings
  has_many :films, through: :selections

  validates :first_name, :last_name, presence: true
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }

  def name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name.first}#{last_name.first}"
  end
end
