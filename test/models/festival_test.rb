require "test_helper"

class FestivalTest < ActiveSupport::TestCase
  test "should not be valid if end_date is before start_date" do
    festival = festivals(:base)
    festival.end_date = festival.start_date - 1.day

    assert_not(festival.valid?)
    assert(festival.errors.full_messages.first.include?("must be greater than"))
  end

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

  test "should not be valid if year is not an integer" do
    festival = festivals(:base)
    festival.year = 2023.5

    assert_not(festival.valid?)
    assert(festival.errors.full_messages.first.include?("must be an integer"))
  end

  test "should not be valid if year is less than 2023" do
    festival = festivals(:base)
    festival.year = 2022

    assert_not(festival.valid?)
    assert(festival.errors.full_messages.first.include?("must be greater than"))
  end

  test "should not be valid if required fields are not present" do
    festival = Festival.new

    assert_not(festival.valid?)
  end

  test "should be valid with all required fields present" do
    festival = festivals(:base)

    assert(festival.valid?)
  end

  test "::current should return current festival" do
    festival = festivals(:base)
    festival.update(start_date: Date.current - 1.day, end_date: Date.current + 1.day)

    assert(Festival.current == festival)
  end

  test "::upcoming should return all upcoming festivals" do
    festival = festivals(:base)
    festival.update(start_date: Date.current + 1.day, end_date: Date.current + 2.days)

    assert(Festival.upcoming.include?(festival))
  end

  test "::past should return all past festivals" do
    festival = festivals(:base)
    festival.update(end_date: Date.current - 1.day, start_date: Date.current - 2.days)

    assert(Festival.past.include?(festival))
  end
end
