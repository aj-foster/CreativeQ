class OrdersController < ApplicationController

	before_filter :authenticate_user!

	def index
		@superset = Order.where.not(status: "Complete").order(due: :asc)
		@unapproved, @unclaimed, @orders = [], [], []

		@superset.each do |order|
			if can? :read, order
				if order.status == "Unapproved" && can?(:approve, order)
					@unapproved << order
				elsif order.status == "Unclaimed" && can?(:claim, order)
					@unclaimed << order
				else
					@orders << order
				end
			end
		end
	end


	def completed
		@orders = Order.where(status: "Complete")
	end


	def show
		@order = Order.find(params[:id])

		unless can? :read, @order
			return redirect_to orders_path, alert: "You aren't allowed to view that order."
		end

		@organization = @order.organization
		@owner = @order.owner
	end


	def new
		@order = Order.new
	end


	def create
		unless can? :create, Order
			return redirect_to orders_path, alert: "You aren't allowed to create orders."
		end

		@order = Order.new(order_params)
		@order.owner = current_user
		@order.validate_due_date unless can?(:manage, @order)

		if @order.save
			redirect_to @order, notice: "Order created successfully."
		else
			render 'new'
		end
	end


	def edit
		@order = Order.find(params[:id])
	end


	def update
		@order = Order.find(params[:id])

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
			redirect_to orders_path, notice: "Order deleted successfully."
		else
			redirect_to @order, alert: "Error: Order could not be deleted."
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
			return redirect_to orders_path, alert: "You can't claim this order."
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

		@order.update_attribute(:status, params[:status])

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