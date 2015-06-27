class User < ActiveRecord::Base

	devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable

	ROLES = %w[Unapproved Basic Creative Admin Retired]

	before_destroy :unlink_orders

	has_many :assignments, dependent: :destroy
	has_many :organizations, through: :assignments

	has_many :orders, inverse_of: :owner, foreign_key: 'owner_id'
	has_many :claimed_orders, class_name: 'Order', inverse_of: :creative, foreign_key: 'creative_id'

	has_many :comments, dependent: :destroy

	validates :first_name, :last_name, presence: true
	validate :validate_creative_flavor


	def active_for_authentication?
		super && self.role != "Retired"
	end


	def can_receive_emails?
		!!(/@ucf.edu$/.match email)
	end


	def name
		first_name + " " + last_name
	end


	def send_emails?
		can_receive_emails? && read_attribute(:send_emails) && role != "Retired"
	end


	def unlink_orders
		Order.where(owner_id: id).each do |order|
			order.update(owner: nil)
		end
	end


	def validate_creative_flavor
		if self.role == "Creative" && self.flavor.blank?
			errors.add :flavor, "must be given for Creatives (Graphics, Web, or Video)."
		end
	end
end