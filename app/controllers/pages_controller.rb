class PagesController < ApplicationController

	def home
		if user_signed_in?
			if can? :manage, Order
				@unapproved_orders = Order.where(status: "Unapproved").count
				@unclaimed_orders = Order.where(status: "Unclaimed").count
				@claimed_orders = Order.count(:creative_id)
			else
				@unapproved_orders = Order.readable(current_user).where(status: "Unapproved").count
				@unclaimed_orders = Order.readable(current_user).where(status: "Unclaimed").count
				@claimed_orders = Order.readable(current_user).count(:creative_id)
			end

			if can? :manage, User
				@unapproved_users = User.where(role: "Unapproved").count
			end
		end
	end
end