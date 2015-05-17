class OrdersMailer < ActionMailer::Base
	default from: "CreativeQ <osiweb@ucf.edu>"

	def order_awaiting_approval (order)
		@order = order
		recipients = Assignment.where(organization: @order.organization).where(role: "Advisor")
					.joins(:user).map{ |a| a.user.email if a.user.send_emails? }.compact
		if recipients.any?
			mail(to: recipients, subject: "[CreativeQ] Order Awaiting Approval: #{@order.name}")
		end
	end
end