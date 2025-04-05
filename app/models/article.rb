# frozen_string_literal: true

class Article < ApplicationRecord
  include FriendlyId

  has_rich_text :content

  belongs_to :critic
end
