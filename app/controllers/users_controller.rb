class UsersController < ApplicationController

	before_filter :authenticate_user!


	def index
		unless can? :manage, User
			return redirect_to current_user, alert: "You aren't allowed to list users."
		end

		@superset = User.includes(:organizations).where.not(role: "Retired").order(last_name: :asc)
		@unapproved, @users = [], []

		@superset.each do |user|
			if user.role == "Unapproved"
				@unapproved << user
			else
				@users << user
			end
		end
	end


	def retired
		unless can? :manage, User
			return redirect_to current_user, alert: "You aren't allowed to list users."
		end

		@users = User.where(role: "Retired").order(last_name: :asc)
	end


	def show
		@user = User.find(params[:id])

		unless can? :read, @user
			return redirect_to root_url, alert: "You aren't allowed to view this profile."
		end

		@assignments = @user.assignments.joins(:organization).order("organizations.name ASC")
		@orgs, @otherOrgs = [], []
		
		Organization.all.order(name: :asc).each do |org|
			if @user.organizations.include?(org)
				@orgs << org
			else
				@otherOrgs << org
			end
		end

		if @user.role == "Creative"
			@orders = Order.where(creative_id: @user.id).limit(5)
		else
			@orders = Order.where(owner_id: @user.id).limit(5)
		end
	end


	def update
		@user = User.find(params[:id])

		unless can? :update, @user
			return redirect_to @user, alert: "You aren't allowed to edit this profile."
		end

		if params[:user][:password].blank?
			params[:user].delete(:password)
			params[:user].delete(:password_confirmation)

			if @user.update_attributes(user_params)
				redirect_to @user, notice: "Profile updated successfully."
			else
				redirect_to @user, alert: @user.errors.full_messages.first
			end

		else
			if @user.update_attributes(user_params)
				sign_in(current_user, :bypass => true) if current_user.id == @user.id
				redirect_to @user, notice: "Password updated."
			else
				redirect_to @user, alert: @user.errors.full_messages.first
			end
		end
	end


	def destroy
		@user = User.find(params[:id])

		unless can? :destroy, @user
			return redirect_to root_url, alert: "You aren't allowed to delete this user."
		end

		if @user.destroy
			redirect_to users_path, notice: "User successfully deleted."
		else
			redirect_to @user, alert: "Error: User could not be deleted."
		end
	end


	private
		def user_params
			if can? :manage, User
				params.require(:user).permit!
			else
				params.require(:user).permit(:first_name,
					:last_name, :email, :phone,
					:password, :password_confirmation)
			end
		end
end