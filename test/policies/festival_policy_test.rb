# frozen_string_literal: true

require "test_helper"

class FestivalPolicyTest < ActiveSupport::TestCase
  def setup
    @admin_user = users(:admin)
    @critic_user = users(:critic)
    @unverified_user = users(:unverified_user)
    @unauthenticated_user = nil
    @record = mock("record")
  end

  # def test_scope
  #   # Add scope tests if FestivalPolicy defines custom scope behavior
  # end

  def test_show
    # By default, show? returns false in ApplicationPolicy
    assert_not(FestivalPolicy.new(@admin_user, @record).show?)
    assert_not(FestivalPolicy.new(@critic_user, @record).show?)
    assert_not(FestivalPolicy.new(@unverified_user, @record).show?)
    assert_not(FestivalPolicy.new(@unauthenticated_user, @record).show?)
  end

  def test_create
    # create? returns true if user is admin
    assert(FestivalPolicy.new(@admin_user, @record).create?)
    assert_not(FestivalPolicy.new(@critic_user, @record).create?)
    assert_not(FestivalPolicy.new(@unverified_user, @record).create?)
    assert_not(FestivalPolicy.new(@unauthenticated_user, @record).create?)
  end

  def test_update
    # update? returns true if user is admin
    assert(FestivalPolicy.new(@admin_user, @record).update?)
    assert_not(FestivalPolicy.new(@critic_user, @record).update?)
    assert_not(FestivalPolicy.new(@unverified_user, @record).update?)
    assert_not(FestivalPolicy.new(@unauthenticated_user, @record).update?)
  end

  def test_destroy
    # destroy? returns true if user is admin
    assert(FestivalPolicy.new(@admin_user, @record).destroy?)
    assert_not(FestivalPolicy.new(@critic_user, @record).destroy?)
    assert_not(FestivalPolicy.new(@unverified_user, @record).destroy?)
    assert_not(FestivalPolicy.new(@unauthenticated_user, @record).destroy?)
  end

  def test_new
    # new? delegates to create?
    assert(FestivalPolicy.new(@admin_user, @record).new?)
    assert_not(FestivalPolicy.new(@critic_user, @record).new?)
    assert_not(FestivalPolicy.new(@unverified_user, @record).new?)
    assert_not(FestivalPolicy.new(@unauthenticated_user, @record).new?)
  end

  def test_edit
    # edit? delegates to update?
    assert(FestivalPolicy.new(@admin_user, @record).edit?)
    assert_not(FestivalPolicy.new(@critic_user, @record).edit?)
    assert_not(FestivalPolicy.new(@unverified_user, @record).edit?)
    assert_not(FestivalPolicy.new(@unauthenticated_user, @record).edit?)
  end

  def test_index
    # index? returns false by default
    assert_not(FestivalPolicy.new(@admin_user, @record).index?)
    assert_not(FestivalPolicy.new(@critic_user, @record).index?)
    assert_not(FestivalPolicy.new(@unverified_user, @record).index?)
    assert_not(FestivalPolicy.new(@unauthenticated_user, @record).index?)
  end
end
