class User < ActiveRecord::Base

	devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable
	ROLES = %w[Unapproved Basic Creative Admin]
	after_initialize :setup_user

	has_many :assignments
	has_many :organizations, through: :assignments

	has_many :orders, inverse_of: :owner, foreign_key: 'owner_id'
	has_many :claimed_orders, class_name: 'Order', inverse_of: :creative, foreign_key: 'creative_id'


	validates :first_name, :last_name, presence: true


	def name
		first_name + " " + last_name
	end


	private
		def setup_user
			self.role ||= ROLES[0]
		end
end