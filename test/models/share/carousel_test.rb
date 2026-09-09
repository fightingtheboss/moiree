# frozen_string_literal: true

require "test_helper"

class Share::CarouselTest < ActiveSupport::TestCase
  class StubCard
    def initialize(slide)
      @slide = slide
    end

    def build(width:, height:)
      Vips::Image.black(width, height, bands: 3)
    end
  end

  class StubContent
    Slide = Struct.new(:label)

    def slides
      [Slide.new("a"), Slide.new("b")]
    end

    def card_class_for(_slide)
      StubCard
    end

    def caption
      "stub caption"
    end
  end

  test "#images renders one image per slide at the requested size" do
    carousel = Share::Carousel.new(StubContent.new, width: 200, height: 300)

    images = carousel.images

    assert_equal 2, images.size
    images.each do |image|
      assert_equal 200, image.width
      assert_equal 300, image.height
    end
  end

  test "#caption delegates to the content object" do
    carousel = Share::Carousel.new(StubContent.new, width: 200, height: 200)

    assert_equal "stub caption", carousel.caption
  end
end
