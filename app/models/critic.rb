# frozen_string_literal: true

class Critic < ApplicationRecord
  include Userable, Attendee
  include FriendlyId

  has_many :editions, through: :attendances

  has_many :ratings, dependent: :destroy do
    def for(edition)
      joins(:selection).where(ratings: { selections: { edition_id: edition.id } })
    end
  end
  has_many :selections, through: :ratings
  has_many :films, through: :selections

  validates :first_name, :last_name, presence: true
  validates :country, inclusion: { in: ISO3166::Country.all.map(&:alpha2) }

  friendly_id :slug_candidates, use: :slugged

  def name
    "#{first_name} #{last_name}"
  end

  def initials
    "#{first_name.first}#{last_name.first}"
  end

  private

  def slug_candidates
    [
      :name,
      [:name, :country],
      [:name, :country, :publication],
    ]
  end
end
