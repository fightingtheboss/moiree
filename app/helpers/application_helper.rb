# frozen_string_literal: true

module ApplicationHelper
  def description(content)
    content_for(:description) { "#{content} on MOIRÉE" }
  end

  def open_graph(edition)
    content_for(:open_graph, open_graph_tags(edition))
  end

  def open_graph_tags(edition)
    tags = {
      title: edition.code,
      url: edition_url(edition),
      image: overview_edition_share_url(edition),
      description: content_for(:description),
      site_name: "MOIRÉE",
      locale: "en_US",
    }

    tags.map do |key, value|
      tag(:meta, property: "og:#{key}", content: value)
    end.join.html_safe
  end
end
