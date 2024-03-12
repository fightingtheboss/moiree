require "test_helper"

class AdminTest < ActiveSupport::TestCase
  test "#name returns username when set" do
    admin = admins(:base)

    assert(admin.name == admin.username)
  end

  test "#name returns email when username not set" do
    admin = admins(:base)
    admin.username = nil

    assert(admin.name == admin.email)
  end

  test "#initials returns username initials when set" do
    admin = admins(:base)

    assert(admin.initials == "B")
  end

  test "#initials returns email initials when username not set" do
    admin = admins(:base)
    admin.username = nil

    assert(admin.initials == "A")

    admin.user.email = "danny.kasman.is.the.best@moire.reviews"

    assert(admin.initials == "D")
  end
end
