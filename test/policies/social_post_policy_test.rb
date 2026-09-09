# frozen_string_literal: true

require "test_helper"

class SocialPostPolicyTest < ActiveSupport::TestCase
  setup do
    @admin_user = users(:admin)
    @critic_user = users(:critic)
    @record = SocialPost.new
  end

  test "only admins can create" do
    assert SocialPostPolicy.new(@admin_user, @record).create?
    assert_not SocialPostPolicy.new(@critic_user, @record).create?
    assert_not SocialPostPolicy.new(nil, @record).create?
  end

  test "only admins can view" do
    assert SocialPostPolicy.new(@admin_user, @record).show?
    assert_not SocialPostPolicy.new(@critic_user, @record).show?
    assert_not SocialPostPolicy.new(nil, @record).show?
  end
end
