class DisableEmailsForExistingUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      if !(/@ucf.edu$/.match user.email)
        user.send_emails = false
        user.save
      end
    end
  end
end
