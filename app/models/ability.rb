class Ability
	include CanCan::Ability

	def initialize(user)

		user ||= User.new

		can :manage, :all if user.role == "Admin"

		can :index, Order
		can :create, Order unless user.role == "Unapproved"
		can :approve, Order if user.assignments.where(organization_id: Order.organization.id).where(status: "Advisor").any?
		can [:claim, :unclaim], Order if user.role == "Creative"
		can [:change_status, :complete], Order, :creative_id => user.id

		can [:read, :update], User, :id => user.id
	end
end