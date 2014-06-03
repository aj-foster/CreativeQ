class OrdersMailer < ActionMailer::Base
	default from: "CreativeQ <osiweb@ucf.edu>"

	def order_awaiting_approval (order)
		@order = order
		mail(to: Assignment.where(organization: @order.organization).where(role: "Advisor")
			.joins(:user).map{ |a| a.user.email },
			subject: "[CreativeQ] Order Awaiting Approval: #{@order.name}")
	end
end