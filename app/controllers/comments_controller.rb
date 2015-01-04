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
			redirect_to @order, notice: "Your comment has been added."
		else
			redirect_to @order, alert: "Error: Could not add comment."
		end
	end


	def destroy
		@comment = Comment.find(params[:id])
		@order = @comment.order
		
		unless can? :destroy, @comment
			return redirect_to @order, alert: "You aren't allowed to delete that comment."
		end

		if @comment.destroy
			redirect_to @order, notice: "Comment removed."
		else
			redirect_to @order, alert: "Error: Comment could not be removed."
		end
	end


	private
		def comment_params
			params.require(:comment).permit!
		end
end