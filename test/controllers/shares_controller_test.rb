# frozen_string_literal: true

require "test_helper"

class SharesControllerTest < ActionDispatch::IntegrationTest
  test "serves PNG share image if attached" do
    edition = editions(:base)
    # Attach a dummy image
    edition.share_image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/dummy.png")),
      filename: "dummy.png",
      content_type: "image/png",
    )

    get overview_edition_share_url(edition, format: :png)

    assert_response :success
    assert_equal "image/png", @response.media_type
  end

  test "returns not found if no share image attached" do
    edition = editions(:with_no_films)
    edition.share_image.purge if edition.share_image.attached?

    get overview_edition_share_url(edition, format: :png)

    assert_response :not_found
  end
end
