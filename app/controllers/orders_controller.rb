class OrdersController < ApplicationController

	before_filter :authenticate_user!

	def index
		@superset = Order.where.not(status: "Complete")
		@orders, @unapproved = [], []

		@superset.each do |order|
			
			if order.status == "Unapproved" && can?(:approve, order)
				@unapproved << order
			elsif can? :read, order
				@orders << order
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

		@order.validate_due_date unless (can? :manage, @order)

		if @order.save
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
	end


	def unclaim
		@order = Order.find(params[:id])
	end


	private
		def order_params
			params.require(:order).permit(:name, :due, :description).tap do |whitelisted|
				whitelisted[:needs] = params[:order][:needs]
				whitelisted[:event] = params[:order][:event]
			end
		end
end