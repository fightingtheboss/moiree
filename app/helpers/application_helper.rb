# frozen_string_literal: true

module ApplicationHelper
  def description(content)
    content_for(:description) { "#{content} on MOIRÉE" }
  end
end
