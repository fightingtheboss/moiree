class UserMailerPreview < ActionMailer::Preview
  def passwordless
    UserMailer.with(user: User.first).passwordless
  end

  def critic_invitation_instructions
    UserMailer.with(user: Critic.first.user, inviting_user: Admin.first.user).critic_invitation_instructions
  end

  def invitation_instructions
    UserMailer.with(user: User.first).invitation_instructions
  end
end
