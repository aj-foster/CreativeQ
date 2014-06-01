class User < ActiveRecord::Base

	devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable

	ROLES = %w[Unapproved Basic Creative Admin Retired]

	after_initialize :setup_user
	before_destroy :unlink_orders

	has_many :assignments, dependent: :destroy
	has_many :organizations, through: :assignments

	has_many :orders, inverse_of: :owner, foreign_key: 'owner_id'
	has_many :claimed_orders, class_name: 'Order', inverse_of: :creative, foreign_key: 'creative_id'


	validates :first_name, :last_name, presence: true
	validate :validate_creative_flavor


	def active_for_authentication?
		super && self.role != "Retired"
	end


	def name
		first_name + " " + last_name
	end


	def unlink_orders
		Order.where(owner_id: id).each do |order|
			order.owner = nil
		end
	end


	def validate_creative_flavor
		if self.role == "Creative" && self.flavor.nil?
			errors.add :flavor, "must be given for Creatives (Graphics, Web, or Video)."
		end
	end


	private
		def setup_user
			self.role ||= ROLES[0]
		end
end