# frozen_string_literal: true

require "test_helper"

class FestivalTest < ActiveSupport::TestCase
  test "should not be valid if given an invalid country code" do
    festival = festivals(:base)
    festival.country = "INVALID"

    assert_not(festival.valid?)
    assert(festival.errors.full_messages.first.include?("is not included"))
  end

  test "should not be valid with invalid URL" do
    festival = festivals(:base)
    festival.url = "INVALID"

    assert_not(festival.valid?)
    assert(festival.errors.full_messages.first.include?("is not a valid URL"))
  end

  test "should not be valid if required fields are not present" do
    festival = Festival.new

    assert_not(festival.valid?)
  end

  test "should be valid with all required fields present" do
    festival = festivals(:base)

    assert(festival.valid?)
  end

  test "#current_edition should return current festival edition" do
    festival = festivals(:base)
    edition = editions(:base)

    edition.update(start_date: Date.current - 1.day, end_date: Date.current + 1.day)

    assert(festival.current_edition.first == edition)
  end

  test "#upcoming_editions should return all upcoming festival editions" do
    festival = festivals(:base)
    edition = editions(:base)

    edition.update(start_date: Date.current + 1.day, end_date: Date.current + 2.days)

    assert(festival.upcoming_editions.include?(edition))
  end

  test "#past_editions should return all past festival editions" do
    festival = festivals(:base)
    edition = editions(:base)

    edition.update(end_date: Date.current - 1.day, start_date: Date.current - 2.days)

    assert(festival.past_editions.include?(edition))
  end
end
