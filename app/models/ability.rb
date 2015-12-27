class Ability
	include CanCan::Ability

	def initialize(user)

		user ||= User.new
		alias_action :read, :update, :destroy, :to => :rud

		can :manage, :all if user.role == "Admin"

		can :index, Order
		can :read, Order, Order.readable(user) do |order|
			order.readable?(user)
		end

		if user.role == "Creative"
			can :read, Order do |order|
				# This is likely redundant and most definitely wrong.
				order.creative.present? && order.flavor == user.flavor
			end

			can :claim, Order, :status => "Unclaimed", :flavor => user.flavor
			can [:unclaim, :change_progress, :complete, :comment_on], Order, :creative_id => user.id
		end

		can [:rud, :comment_on], Order, :owner_id => user.id
		can [:rud, :comment_on], Order, :organization_id => user.assignments.advised.pluck(:organization_id)

		can :create, Order unless user.role == "Unapproved"

		can :initial_approve, Order, :organization_id => user.assignments.advised.pluck(:organization_id)

		cannot :student_approve, Order if user.role == "Admin"
		can :student_approve, Order, :owner_id => user.id, :student_approval => nil

		cannot :advisor_approve, Order if user.role == "Admin"
		can :advisor_approve, Order, :organization_id => user.assignments.advised.pluck(:organization_id)

		can [:read, :update], User, :id => user.id

		can :destroy, Comment, :user_id => user.id
	end
end