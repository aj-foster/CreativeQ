class AddEmailOptionToUsers < ActiveRecord::Migration
  def up
    add_column :users, :send_emails, :boolean, null: false, default: true

    User.find_each do |user|
      unless /@ucf.edu$/.match user.email
        user.send_emails = false
        user.save!
      end
    end
  end

  def down
    remove_column :users, :send_emails
  end
end
