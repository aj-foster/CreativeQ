class OrdersController < ApplicationController

	before_filter :authenticate_user!

	def index

		# Although this method works, I don't much like it.  As much as possible,
		# it would be nice to defer the selection sorting (i.e. can? :read) to
		# the database.  In general, the database is going to be able to sort
		# through records faster than Ruby.  Doing so -is- possible if you use
		# Arel, which I would rather not do for posterity's sake.  It is possible
		# that pull request #9052 on rails/rails will be merged into 4.2.0, so
		# we can use #or.

		# How I might do it differently:
		# - Claimable, advisable, and completed would all be scopes on Order.
		# - (Readable would use #or with the other scopes)
		# - Record selection and CanCan would both use these scopes to be DRY.

		@superset = Order.where.not(status: "Complete").order(due: :asc)
		@unapproved, @unclaimed, @claimed, @orders = [], [], [], []

		@superset.each do |order|
			if can? :read, order
				if order.status == "Unapproved" && can?(:approve, order)
					@unapproved << order
				elsif order.status == "Unclaimed" && can?(:claim, order)
					@unclaimed << order
				elsif order.creative == current_user
					@claimed << order
				else
					@orders << order
				end
			end
		end
	end


	def completed
		if can? :manage, Order
			@orders = Order.where(status: "Complete").page(params[:page]).order(due: :desc)
		else
			@orders = Order.completed(current_user).page(params[:page]).order(due: :desc)
		end
	end


	def show
		@order = Order.find(params[:id])

		unless can? :read, @order
			return redirect_to orders_path, alert: "You aren't allowed to view that order."
		end

		case @order.flavor
		when "Graphics"
			@needs = Order.graphics_needs
		when "Web"
			@needs = Order.web_needs
		when "Video"
			@needs = Order.video_needs
		end
		
		@organization = @order.organization
		@owner = @order.owner
		@creative = @order.creative
	end


	def new
		@order = Order.new
		@can_edit_organization = true
	end


	def create
		unless can? :create, Order
			return redirect_to orders_path, alert: "You aren't allowed to create orders."
		end

		@order = Order.new(order_params)
		@order.owner = current_user
		@order.validate_due_date unless can?(:manage, @order)

		if @order.save
			redirect_to @order, notice: "Your order has been submitted to your advisor for approval."
			OrdersMailer.order_awaiting_approval(@order).deliver
		else
			render 'new'
		end
	end


	def edit
		@order = Order.find(params[:id])
		@can_edit_organization = current_user.organizations.pluck(:id).include?(@order.organization_id)
	end


	def update
		@order = Order.find(params[:id])
		@can_edit_organization = current_user.organizations.pluck(:id).include?(@order.organization_id)

		unless can? :update, @order
			return redirect_to @order, alert: "You aren't allowed to edit this order."
		end

		@order.assign_attributes(order_params)
		@order.setup_order
		@valid_date = can?(:manage, @order) ? true : @order.validate_due_date

		if @valid_date && @order.save
			redirect_to @order, notice: "Order updated successfully."
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
		else
			respond_to do |format|
				format.html {
					redirect_to @order, alert: "Error: Order could not be deleted."
				}
			end
		end
	end


	def approve
		@order = Order.find(params[:id])

		unless can? :approve, @order
			return redirect_to @order, alert: "You aren't allowed to approve this order."
		end

		@order.status = "Unclaimed" if @order.status == "Unapproved"
		@order.save
		
		respond_to do |format|
			format.js
		end
	end


	def claim
		@order = Order.find(params[:id])

		unless can? :claim, @order
			return redirect_to orders_path, alert: "You can't claim this order. It might have already been claimed."
		end

		@order.status = "Claimed"
		@order.creative = current_user

		if @order.save
			redirect_to @order, notice: "Order claimed successfully. Please begin by e-mailing its owner."
		else
			redirect_to @order, alert: "Error: Could not claim this order."
		end
	end


	def unclaim
		@order = Order.find(params[:id])

		unless can? :unclaim, @order
			return redirect_to @order, alert: "You can't unclaim this order."
		end

		@order.status = "Unclaimed"
		@order.creative = nil
		
		if @order.save
			redirect_to orders_path, notice: "Order unclaimed successfully."
		else
			redirect_to @order, alert: "Error: Could not unclaim this order."
		end
	end


	def change_status
		@order = Order.find(params[:id])

		unless can? :change_status, @order
			return redirect_to @order, alert: "You aren't allowed to change this order's status."
		end

		@order.update_attribute(:status, params[:order][:status])

		respond_to do |format|
			format.js
		end
	end


	private
		def order_params
			params.require(:order).permit(:name, :due, :description, :flavor, :organization_id).tap do |whitelisted|
				whitelisted[:needs] = params[:order][:needs]
				whitelisted[:event] = params[:order][:event]
			end
		end
end