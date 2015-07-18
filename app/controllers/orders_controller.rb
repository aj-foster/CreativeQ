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

		@needs = @order.class.needs
		@organization = @order.organization
		@owner = @order.owner
		@creative = @order.creative
	end


	def new
		unless can? :create, Order
			return redirect_to orders_path, alert: "You aren't allowed to create orders."
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
		@order.validate_due_date unless can?(:manage, @order)

		@order.subscribe @order.owner
		@order.subscribe @order.advisors

		if @order.save
			redirect_to order_path(@order), notice: "Your order has been submitted to your advisor for approval."
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

		unless can? :approve, @order
			return redirect_to order_path(@order), alert: "You aren't allowed to approve this order."
		end

		@order.status = "Unclaimed" if @order.status == "Unapproved"
		@order.save
		@order.comments.create(message: "#{current_user.name} approved this order.")

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

		@order.update_attribute(:progress, params[:order][:progress])
		@order.comments.create(message: "#{current_user.name} set the order progress to #{params[:order][:progress]}.")

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


	private
		def order_params
			params.require(:order).permit(:name, :due, :description, :flavor, :organization_id).tap do |whitelisted|
				whitelisted[:needs] = params[:order][:needs] if params[:order][:needs]
				whitelisted[:event] = params[:order][:event] if params[:order][:event]
			end
		end
end
