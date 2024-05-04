# frozen_string_literal: true

require "test_helper"

class Admin::CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_festival_edition_categories_url(festivals(:base), editions(:base))
    assert_response :success
  end

  test "should reorder successfully" do
    patch reorder_admin_festival_edition_category_url(
      festivals(:base),
      editions(:base),
      categories(:base),
      params: { position: 2 },
    )

    assert_response :success
  end
end
