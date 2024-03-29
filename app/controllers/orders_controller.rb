class OrdersController < ApplicationController

	before_filter :authenticate_user!

	def index

		@pending_initial = Order.advised_by(current_user)
			.where(status: "Unapproved")
			.order(due: :asc)
			.includes(:organization)
			.to_a

		@pending_advisor = Order.advised_by(current_user)
			.where.not(status: "Complete")
			.where.not(student_approval: nil)
			.where(advisor_approval: nil)
			.order(due: :asc)
			.includes(:organization)
			.to_a

		@pending_final = can?(:final_approve, Order) ? Order
			.where.not(status: "Complete")
			.where.not(advisor_approval: nil)
			.where(final_two: nil)
			.order(due: :asc)
			.includes(:organization)
			.to_a
			: []

		@recent_complete = Order.readable(current_user)
			.where(status: "Complete")
			.where("completed_at >= ?", DateTime.now - 1.week)
			.order(completed_at: :desc)
			.includes(:organization, :creative)
			.to_a

		@unclaimed = Order.claimable_by(current_user)
			.where.not(status: "Complete")
			.order(due: :asc)
			.includes(:organization)
			.to_a

		@claimed = Order.claimed_by(current_user)
			.where.not(status: "Complete")
			.order(due: :asc)
			.includes(:organization, :creative)
			.to_a

		seen_ids = @pending_initial.map(&:id) |
							 @pending_advisor.map(&:id) |
 							 @pending_final.map(&:id) |
							 @unclaimed.map(&:id)  |
							 @claimed.map(&:id)

		@orders = Order.readable(current_user)
			.where.not(status: "Complete", id: seen_ids)
			.order(due: :asc)
			.includes(:organization, :creative)
			.to_a
	end


	def assignments
		@orders = Order.readable(current_user)
			.joins(:creative)
			.where.not(status: "Complete", creative_id: nil)
			.order("users.last_name")
			.order(due: :asc)
			.includes(:organization, :creative)
			.to_a
			.group_by { |order| order.creative.name }
	end


	def completed
		if can? :manage, Order
			@orders = Order.where(status: "Complete")
				.page(params[:page])
				.order("completed_at DESC NULLS LAST, due DESC")
				.includes(:organization, :creative)
		else
			@orders = Order.completed(current_user)
				.page(params[:page])
				.order("completed_at DESC NULLS LAST, due DESC")
				.includes(:organization, :creative)
		end
	end


	def show
		@order = Order.find(params[:id])

		unless can? :read, @order
			return redirect_to orders_path, alert: "You aren't allowed to view that order."
		end

		@needs = @order.class.needs
		@organization = @order.organization
		@owner = @order.owner
		@creative = @order.creative
	end


	def new
		unless can? :create, Order
			return redirect_to orders_path, alert: "You aren't allowed to create orders."
		end

		unless current_user.organizations.count > 0
			return redirect_to orders_path, alert: "Please ask the administrator to assign you to a group"
		end

		@order = Order.new
		@can_edit_organization = true
	end


	def create
		unless can? :create, Order
			return redirect_to orders_path, alert: "You aren't allowed to create orders."
		end

		@flavor = params[:order][:flavor]
		params[:order].delete(:flavor)

		case @flavor
		when "Graphics"
			@order = GraphicOrder.new(order_params)
		when "Web"
			@order = WebOrder.new(order_params)
		when "Video"
			@order = VideoOrder.new(order_params)
		end

		@order.owner = current_user

		# Warning: This is extremely flaky. There's something weird going on with
		# the validation. valid = @order.valid? && @order.validate_due_date
		# Does not add the due date errors to the errors object. Different orders
		# of evaluation, assignment, and &&'ing them cause different results.
		valid = @order.valid?
		due_date_valid = (can?(:manage, @order) ? true : @order.validate_due_date)

		if valid && due_date_valid && @order.save
			redirect_to order_path(@order), notice: "Your order has been submitted to your advisor for approval."
			@order.subscribe @order.owner
			@order.subscribe @order.advisors
			Notification.notify_order_created(@order, current_user)
		else
			@can_edit_organization = true
			render 'new'
		end
	end


	def edit
		@order = Order.find(params[:id])

		unless can? :update, @order
			return redirect_to order_path(@order), alert: "You aren't allowed to edit this order."
		end

		@can_edit_organization = current_user.organizations.pluck(:id).include?(@order.organization_id)
	end


	def update
		@order = Order.find(params[:id])
		@can_edit_organization = current_user.organizations.pluck(:id).include?(@order.organization_id)
		params[:order].delete(:flavor)

		unless can? :update, @order
			return redirect_to order_path(@order), alert: "You aren't allowed to edit this order."
		end

		@order.assign_attributes(order_params)
		@valid_date = can?(:manage, @order) || @order.validate_due_date

		if @valid_date && @order.save
			redirect_to order_path(@order), notice: "Order updated successfully."
		else
			render 'edit'
		end
	end


	def destroy
		@order = Order.find(params[:id])

		unless can? :destroy, @order
			return redirect_to orders_path, alert: "You aren't allowed to delete this order."
		end

		if @order.destroy
			respond_to do |format|
				format.html {
					redirect_to orders_path, notice: "Order deleted successfully."
				}
				format.js
			end

			Notification.notify_order_removed(@order, current_user)
		else
			respond_to do |format|
				format.html {
					redirect_to order_path(@order), alert: "Error: Order could not be deleted."
				}
			end
		end
	end


	def approve
		@order = Order.find(params[:id])
		@stage = params[:stage] || "initial"

		case @stage
		when "student"
			task = :student_approve
			update_order = Proc.new { |order| order.student_approval = current_user }
			success_notice = "Order approved. It is now ready for your advisor's approval."
			success_comment = "#{current_user.name} approved this order."
			# success_block = Proc.new { |order| Notification.notify_order_pending(order, current_user) }

		when "advisor"
			task = :advisor_approve
			update_order = Proc.new do |order|
				order.advisor_approval = current_user

				if @order.student_approval.nil? && @order.owner == current_user
					@order.student_approval = current_user
				end
			end
			success_notice = "Order successfully given your approval."
			success_comment = "#{current_user.name} approved this order."

		when "final"
			task = :final_approve
			update_order = Proc.new do |order|
				if @order.final_one.nil?
					@order.final_one = current_user
				elsif
					@order.final_two = current_user
					@order.status = "Complete"
					@order.completed_at = DateTime.now
				end

				if @order.student_approval.nil? && @order.owner == current_user
					@order.student_approval = current_user
				end

				if @order.advisor_approval.nil? && (can? :advisor_approve, @order)
					@order.advisor_approval = current_user
				end
			end
			success_notice = "Order successfully given your approval."
			success_comment = "#{current_user.name} approved this order."

		else
			task = :initial_approve
			update_order = Proc.new { |order| order.status = "Unclaimed" if order.status == "Unapproved" }
			success_notice = "Order successfully given initial approval."
			success_comment = "#{current_user.name} gave initial approval."
		end

		unless can? task, @order
			return redirect_to order_path(@order), alert: "You aren't allowed to approve this order."
		end

		update_order.call(@order)

		if @order.save
			respond_to do |format|
				format.html { redirect_to @order, notice: success_notice }
				format.js
			end

			@order.comments.create(message: success_comment)

			# Should be worked into a "success_block" determined by the case
			if @stage == "student"
				Notification.notify_order_pending(@order, current_user)
			end

		else
			return redirect_to @order, alert: "Error: Could not approve order."
		end
	end


	def claim
		@order = Order.find(params[:id])

		unless can? :claim, @order
			return redirect_to orders_path, alert: "You can't claim this order. It might have already been claimed."
		end

		@order.status = "Claimed"
		@order.progress = "Due Date Pending"
		@order.creative = current_user
		@order.subscribe @order.creative

		if @order.save
			redirect_to order_path(@order), notice: "Order claimed successfully. Please begin by e-mailing its owner."
			@order.comments.create(message: "#{current_user.name} claimed this order.")
		else
			redirect_to order_path(@order), alert: "Error: Could not claim this order."
		end
	end


	def unclaim
		@order = Order.find(params[:id])

		unless can? :unclaim, @order
			return redirect_to order_path(@order), alert: "You can't unclaim this order."
		end

		@order.status = "Unclaimed"
		@order.creative = nil
		@order.unsubscribe current_user

		if @order.save
			redirect_to orders_path, notice: "Order unclaimed successfully."
			@order.comments.create(message: "#{current_user.name} unclaimed this order.")
		else
			redirect_to order_path(@order), alert: "Error: Could not unclaim this order."
		end
	end


	def change_progress
		@order = Order.find(params[:id])

		unless can? :change_progress, @order
			return redirect_to order_path(@order), alert: "You aren't allowed to change this order's progress."
		end

		if @order.update_attribute(:progress, params[:order][:progress])
			@saved = true
			@order.comments.create(message: "#{current_user.name} set the order progress to #{params[:order][:progress]}.")
		else
			@saved = false
		end

		respond_to do |format|
			format.js
		end
	end


	def subscribe
		@order = Order.find(params[:id])

		unless can? :read, @order
			return redirect_to orders_path, alert: "You aren't allowed to view this order."
		end

		if @order.subscribe current_user
			redirect_to order_path(@order), notice: "You have been subscribed to notifications."
		else
			redirect_to order_path(@order), alert: "Error: Could not subscribe to notifications."
		end
	end


	def unsubscribe
		@order = Order.find(params[:id])

		if @order.unsubscribe current_user
			redirect_to order_path(@order), notice: "You have been unsubscribed from notifications."
		else
			redirect_to order_path(@order), alert: "Error: Could not unsubscribe from notifications."
		end
	end


	def complete
		@order = Order.find(params[:id])

		unless can? :change_progress, @order
			return redirect_to orders_path, alert: "You aren't allowed to complete this order."
		end

		@order.status = "Complete"
		@order.completed_at = DateTime.now

		if @order.save
			@order.comments.create(message: "#{current_user.name} set the order as complete.")
			redirect_to order_path(@order), notice: "Order has been marked as complete."
		else
			redirect_to order_path(@order), alert: "Error: Could not mark order as complete."
		end
	end


	def uncomplete
		@order = Order.find(params[:id])

		unless can? :manage, @order
			return redirect_to orders_path, alert: "You aren't allowed to revert this order."
		end

		if @order.creative_id != nil
			@order.status = "Claimed"
		else
			@order.status = "Unclaimed"
		end

		@order.completed_at = nil

		if @order.save
			@order.comments.create(message: "#{current_user.name} set the order as incomplete.")
			redirect_to order_path(@order), notice: "Order has been marked as incomplete."
		else
			redirect_to order_path(@order), alert: "Error: Could not mark order as incomplete."
		end
	end


	private
		def order_params
			params.require(:order).permit(:name, :due, :description, :flavor, :organization_id).tap do |whitelisted|
				whitelisted[:needs] = params[:order][:needs] if params[:order][:needs]
				whitelisted[:event] = params[:order][:event] if params[:order][:event]
			end
		end
end
