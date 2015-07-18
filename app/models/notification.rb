class Notification < ActiveRecord::Base

  belongs_to :user
  belongs_to :order

  validates :title, :message, :user, :order, presence: true

  # Marks an order as "read" using its status field.
  #
  def mark_as_read
    self.update(read: true)
  end

  def self.notify_comment_created (comment, current_user)
    order = comment.order

    title = "New Comment on #{order.name}"
    message = "#{comment.user.name} posted a new comment on your order: " +
              "\"#{comment.message.truncate(30, separator: ' ')}\""

    subscriptions = order.subscriptions || []
    subscriptions.delete(current_user.id) unless current_user.nil?

    recipients = User.where(id: subscriptions)
    # emails = recipients.select(&:send_emails?).map(&:email) || []

    recipients.each do |user|
      user.notifications.create(order: order, title: title, message: message)
    end
  end
end