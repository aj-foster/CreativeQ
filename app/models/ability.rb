class Ability
	include CanCan::Ability

	def initialize(user)

		user ||= User.new
		alias_action :read, :update, :destroy, :to => :rud

		can :manage, :all if user.role == "Admin"

		can :index, Order

		can :read, Order { |order| !order.creative.nil? } if user.role == "Creative"
		
		can :rud, Order, :owner_id => user.id
		can :rud, Order, :organization_id => user.assignments.advised.pluck(:organization_id)

		can :create, Order unless user.role == "Unapproved"

		can :approve, Order, :organization_id => user.assignments.advised.pluck(:organization_id)

		can :claim, Order, :status => "Unclaimed", :flavor => user.flavor if user.role == "Creative"
		can [:unclaim, :change_status, :complete], Order, :creative_id => user.id

		can [:read, :update], User, :id => user.id
	end
end