class Ability
	include CanCan::Ability

	def initialize(user)

		user ||= User.new
		alias_action :create, :read, :update, :destroy, :to => :crud

		can :manage, :all if user.role == "Admin"

		can :index, Order

		can :read, Order, :creative_id => [user.id, nil] if user.role == "Creative"
		
		can :crud, Order, :owner_id => user.id
		can :crud, Order, :organization_id => user.assignments.advised.pluck(:organization_id)

		can :create, Order unless user.role == "Unapproved"

		can :approve, Order, :organization_id => user.assignments.advised.pluck(:organization_id)
		# can :approve, Order do |order|
		# 	user.assignments.where(organization_id: order.organization_id).where(role: "Advisor").any?
		# end

		can [:read, :claim], Order, :status => "Unclaimed", :flavor => user.flavor if user.role == "Creative"
		can [:unclaim, :change_status, :complete], Order, :creative_id => user.id

		can [:read, :update], User, :id => user.id
	end
end