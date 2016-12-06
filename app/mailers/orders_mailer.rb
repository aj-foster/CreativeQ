class OrdersMailer < ActionMailer::Base
	default from: "CreativeQ <noreply@nqueue.io>"

	def order_awaiting_initial_approval (order, emails)
		@order = order

		if emails.any?
			mail(to: emails, subject: "[CreativeQ] Awaiting Initial Approval: #{@order.name}")
		end
	end

	def order_awaiting_advisor_approval (order, emails)
		@order = order

		if emails.any?
			mail(to: emails, subject: "[CreativeQ] Awaiting Advisor Approval: #{@order.name}")
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