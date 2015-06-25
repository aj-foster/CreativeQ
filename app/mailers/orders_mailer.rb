class OrdersMailer < ActionMailer::Base
	default from: "CreativeQ <osiweb@ucf.edu>"

	def order_awaiting_approval (order)
		@order = order
		recipients = @order.advisors.select(&:send_emails?).map(&:email).compact
		if recipients.any?
			mail(to: recipients, subject: "[CreativeQ] Order Awaiting Approval: #{@order.name}")
		end
	end

  def order_comment_created (order, comment, current_user)
    @order = order
    @comment = comment

    begin
      recipients = User.find(@order.subscriptions || [])
    rescue ActiveRecord::RecordNotFound
      recipients = User.find(@order.subscriptions.map { |uid| User.exists? uid } || [])
    ensure
      recipients.reject! { |user| user.id == current_user.id }
      emails = recipients.select(&:send_emails?).map(&:email) || []
    end

    if emails.any?
      mail(to: emails, subject: "[CreativeQ] New Comment on #{@order.name}")
    end
  end
end