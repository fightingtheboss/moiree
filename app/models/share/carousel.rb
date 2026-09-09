# frozen_string_literal: true

module Share
  class Carousel
    def initialize(content, width:, height:)
      @content = content
      @width = width
      @height = height
    end

    def images
      @images ||= @content.slides.map do |slide|
        @content.card_class_for(slide).new(slide).build(width: @width, height: @height)
      end
    end

    def caption
      @content.caption
    end
  end
end
