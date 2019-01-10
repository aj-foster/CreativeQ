class UsersMailer < ActionMailer::Base
  default from: "CreativeQ <no-reply@nqueue.io>"

  def user_awaiting_approval (user, emails)
    @user = user

    if emails.any?
      mail(to: emails, subject: "[CreativeQ] User Awaiting Approval: #{@user.name}")
    end
  end
end
