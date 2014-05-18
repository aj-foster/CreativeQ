class Organization < ActiveRecord::Base

	before_destroy :unlink_orders


	has_many :assignments
	has_many :users, through: :assignments

	has_many :orders


	def unlink_orders
		Order.where(organization_id: id).each do |order|
			order.organization = nil
		end
	end
end