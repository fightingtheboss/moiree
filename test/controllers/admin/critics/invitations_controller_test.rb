# frozen_string_literal: true

require "test_helper"

class Admin
  module Critics
    class InvitationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @admin = sign_in_as(users(:admin))
      end

      test "should get new" do
        get new_admin_critics_invitation_url
        assert_response :success
      end

      test "should create a new Critic" do
        assert_difference("Critic.count") do
          post admin_critics_invitation_url, params: {
            user: {
              email: "new.user@moire.reviews",
              userable_type: "Critic",
              userable_attributes: {
                first_name: "New",
                last_name: "User",
                publication: "Moirée Reviews",
                country: "US",
              },
            },
          }
        end

        assert_redirected_to new_admin_critics_invitation_url
      end

      test "should send invitation instructions email to new admin" do
        admin = users(:admin)
        critic = users(:critic)

        assert_enqueued_email_with UserMailer, :critic_invitation_instructions, params: { user: critic, inviting_user: admin } do
          post admin_critics_invitation_url, params: { user: { email: critic.email } }
        end

        assert_redirected_to new_admin_critics_invitation_url
      end
    end
  end
end
