class Notification < ActiveRecord::Base

  belongs_to :user
  belongs_to :notable, polymorphic: true

  validates :title, :message, :user, presence: true

  # Marks a notification as "read" using its status field.
  #
  def mark_as_read
    self.update(read: true)
  end

  def self.notify_comment_created (comment, current_user)
    order = comment.order

    title = "New Comment on #{order.name.truncate(30, separator: ' ')}"
    message = "#{comment.user.name} posted a new comment on your order: " +
              "\"#{comment.message.truncate(30, separator: ' ')}\""

    subscriptions = order.subscriptions || []
    subscriptions.delete(current_user.id) unless current_user.nil?

    recipients = User.where(id: subscriptions)
    emails = recipients.select(&:send_emails?).map(&:email) || []

    recipients.each do |user|
      user.notifications.create(notable: order, title: title, message: message)
    end

    OrdersMailer.order_comment_created(comment, emails).deliver
  end

  def self.notify_order_created (order, current_user)
    title = "New Order Awaiting Approval"
    message = "#{order.owner.name} created a new order that needs approval: " +
              "\"#{order.name.truncate(30, separator: ' ')}\""

    recipients = order.advisors.compact || []
    emails = recipients.select(&:send_emails?).map(&:email) || []

    recipients.each do |user|
      user.notifications.create(notable: order, title: title, message: message)
    end

    OrdersMailer.order_awaiting_approval(order, emails).deliver
  end
end