class AssignmentsController < ApplicationController

	def create
		unless can? :manage, User
			return
		end

		@assignment = Assignment.create(assignment_params)
		@assignment.save

		respond_to do |format|
			format.js
		end
	end


	def update
		unless can? :manage, User
			return
		end

		@assignment = Assignment.find(params[:id])
		@assignment.update(assignment_params)

		respond_to do |format|
			format.js
		end
	end


	def destroy
		unless can? :manage, User
			return
		end

		@assignment = Assignment.find(params[:id])
		@assignment.destroy

		respond_to do |format|
			format.js
		end
	end


	private
		def assignment_params
			params.require(:assignment).permit!
		end
end