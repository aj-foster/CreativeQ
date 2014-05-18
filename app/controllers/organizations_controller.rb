class OrganizationsController < ApplicationController

	before_filter :authenticate_user!

	def index
		unless can? :index, Organization
			return redirect_to root_url, alert: "You aren't allowed to list organizations."
		end

		@organizations = Organization.order(name: :asc)
	end


	def create
		unless can? :create, Organization
			return redirect_to organizations_path, alert: "You aren't allowed to create organizations."
		end

		@org = Organization.create(org_params)

		respond_to do |format|
			format.js
		end
	end


	def destroy
		@org = Organization.find(params[:id])

		unless can? :destroy, Organization
			return redirect_to organizations_path, alert: "You aren't allowed to delete organizations."
		end
		
		@org.destroy

		respond_to do |format|
			format.js
		end
	end


	private
		def org_params
			params.require(:organization).permit!
		end
end