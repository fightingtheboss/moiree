# frozen_string_literal: true

require "test_helper"

class Share::Card::FilmRankTest < ActiveSupport::TestCase
  Slide = Struct.new(:selection, :rank, :bayesian_score)

  test "#build returns an image with the exact requested dimensions" do
    slide = Slide.new(selections(:base), 1, 4.2)

    image = Share::Card::FilmRank.new(slide).build(width: 1080, height: 1080)

    assert_equal 1080, image.width
    assert_equal 1080, image.height
  end

  test "#build works for a different aspect ratio without raising" do
    slide = Slide.new(selections(:base), 3, 3.75)

    image = Share::Card::FilmRank.new(slide).build(width: 1080, height: 1350)

    assert_equal 1080, image.width
    assert_equal 1350, image.height
  end

  test "#build produces an opaque image (no alpha band) suitable for a feed post" do
    slide = Slide.new(selections(:base), 1, 4.2)

    image = Share::Card::FilmRank.new(slide).build(width: 500, height: 500)

    assert_equal 3, image.bands
  end
end
