# frozen_string_literal: true

class Podcast < ApplicationRecord
  extend FriendlyId

  TRANSISTOR_SHOW_ID = "moiree-podcast"

  friendly_id :slug_candidates, use: :slugged

  belongs_to :user
  has_many :episodes, dependent: :destroy

  validates :title, :slug, presence: true

  accepts_nested_attributes_for(:episodes, allow_destroy: true)

  scope :platform, -> { where(platform: true) }

  def import_transistor_episodes
    Transistor.published_episodes(TRANSISTOR_SHOW_ID).each do |transistor_episode|
      next if episodes.exists?(provider_id: transistor_episode.id)

      episode = episodes.build(
        provider_id: transistor_episode.id,
        title: transistor_episode.title,
        summary: transistor_episode.summary,
        description: transistor_episode.description,
        url: transistor_episode.share_url,
        embed: transistor_episode.embed_html,
        slug: transistor_episode.slug,
        published_at: transistor_episode.published_at,
        duration: transistor_episode.duration,
      )

      unless episode.save
        Bugsnag.notify(
          "Failed to import Transistor episode #{transistor_episode.id}: #{episode.errors.full_messages.to_sentence}",
        )
      end
    end
  end

  private

  def slug_candidates
    [
      :title,
      [:title, -> { user&.name }],
    ]
  end
end
