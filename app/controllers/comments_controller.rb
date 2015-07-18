class CommentsController < ApplicationController

	def create
		@order = Order.find(comment_params[:order_id])

		unless can? :comment_on, @order
			return redirect_to orders_path, alert: "You aren't allowed to comment on this order."
		end

		@comment = Comment.new(comment_params)
		@comment.user = current_user
		@comment.order = @order

		if @comment.save
			redirect_to order_path(@order), notice: "Your comment has been added."
			Notification.notify_comment_created(@comment, current_user)
			# OrdersMailer.order_comment_created(@order, @comment, current_user).deliver
		else
			redirect_to order_path(@order), alert: "Error: Could not add comment."
		end
	end


	def destroy
		@comment = Comment.find(params[:id])
		@order = @comment.order
		
		unless can? :destroy, @comment
			return redirect_to order_path(@order), alert: "You aren't allowed to delete that comment."
		end

		if @comment.destroy
			redirect_to order_path(@order), notice: "Comment removed."
		else
			redirect_to order_path(@order), alert: "Error: Comment could not be removed."
		end
	end


	private
		def comment_params
			params.require(:comment).permit!
		end
end