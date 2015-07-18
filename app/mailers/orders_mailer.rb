class OrdersMailer < ActionMailer::Base
	default from: "CreativeQ <osiweb@ucf.edu>"

	def order_awaiting_approval (order)
		@order = order
		recipients = @order.advisors.select(&:send_emails?).map(&:email).compact
		if recipients.any?
			mail(to: recipients, subject: "[CreativeQ] Order Awaiting Approval: #{@order.name}")
		end
	end

  def order_comment_created (comment, emails)
    @comment = comment
    @order = comment.order

    if emails.any?
      mail(to: emails, subject: "[CreativeQ] New Comment on #{@order.name}")
    end
  end
end