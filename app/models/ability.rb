class Ability
	include CanCan::Ability

	def initialize(user)

		user ||= User.new

		can :manage, :all if user.role == "Admin"

		can :index, Order
		can :create, Order unless user.role == "Unapproved"
		can :approve, Order do |order|
			user.assignments.where(organization_id: order.organization_id).where(role: "Advisor").any?
		end
		can :claim, Order, :status => "Unclaimed" if user.role == "Creative"
		can [:unclaim, :change_status, :complete], Order, :creative_id => user.id

		can [:read, :update], User, :id => user.id
	end
end