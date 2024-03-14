require "test_helper"

class EditionTest < ActiveSupport::TestCase
  test "should not be valid if end_date is before start_date" do
    edition = editions(:base)
    edition.end_date = edition.start_date - 1.day

    assert_not(edition.valid?)
    assert(edition.errors.full_messages.first.include?("must be greater than"))
  end

  test "should not be valid if year is not an integer" do
    edition = editions(:base)
    edition.year = 2023.5

    assert_not(edition.valid?)
    assert(edition.errors.full_messages.first.include?("must be an integer"))
  end

  test "should not be valid if year is less than 2023" do
    edition = editions(:base)
    edition.year = 2022

    assert_not(edition.valid?)
    assert(edition.errors.full_messages.first.include?("must be greater than"))
  end

  test "should not be valid if required fields are not present" do
    edition = Edition.new

    assert_not(edition.valid?)
  end

  test "should be valid with all required fields present" do
    edition = editions(:base)

    assert(edition.valid?)
  end

  test "::current should return current edition" do
    edition = editions(:base)
    edition.update(start_date: Date.current - 1.day, end_date: Date.current + 1.day)

    assert(Edition.current == edition)
  end

  test "::upcoming should return all upcoming editions" do
    edition = editions(:base)
    edition.update(start_date: Date.current + 1.day, end_date: Date.current + 2.days)

    assert(Edition.upcoming.include?(edition))
  end

  test "::past should return all past editions" do
    edition = editions(:base)
    edition.update(end_date: Date.current - 1.day, start_date: Date.current - 2.days)

    assert(Edition.past.include?(edition))
  end

  test "#url should return the festival URL if not present" do
    edition = editions(:base)

    assert(edition.url == edition.festival.url)
  end

  test "#url should return the edition URL if present" do
    edition = editions(:base)
    edition.url = "http://example.com"

    assert(edition.url == "http://example.com")
  end

  test "#name should return the festival name" do
    edition = editions(:base)

    assert(edition.name == edition.festival.name)
  end

  test "#short_name should return the festival short_name" do
    edition = editions(:base)

    assert(edition.short_name == edition.festival.short_name)
  end

  test "#country should return the festival country" do
    edition = editions(:base)

    assert(edition.country == edition.festival.country)
  end
end
