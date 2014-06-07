class Organization < ActiveRecord::Base

	before_destroy :unlink_orders

	default_scope { order(name: :asc) }


	has_many :assignments, dependent: :destroy
	has_many :users, through: :assignments

	has_many :orders


	def unlink_orders
		Order.where(organization_id: id).each do |order|
			order.organization = nil
		end
	end
end