class Order < ActiveRecord::Base

	STATUSES = ["Unapproved", "Unclaimed", "Due Date Pending", "In-Progress", "Proofing", "Revising", "Awaiting Approval", "Complete"]
	TYPES = %w[Graphics Web Video]
	self.per_page = 20

	belongs_to :owner, class_name: 'User'
	belongs_to :creative, class_name: 'User'
	belongs_to :organization

	has_many :comments, dependent: :destroy


	validates :name, :due, :description, :needs, presence: true

	scope :readable, -> (user) {
		where("owner_id = ? OR creative_id = ? OR (status = 'Unclaimed' AND
		flavor = ?) OR organization_id IN (?)", user.id, user.id, user.flavor,
		user.assignments.advised.pluck(:organization_id))
	}

	scope :completed, -> (user) { where(status: "Complete").where("owner_id = ? OR
		creative_id = ? OR organization_id IN (?)", user.id, user.id,
		user.assignments.advised.pluck(:organization_id)) }

	class << self
		def graphics_needs
			["Handbill", "Poster", "A-Frame", "Banner", "Newspaper", "T-Shirt",
			 "Logo", "Brochure", "Program", "FB Event Photo", "OSI Banner", "OSI Front Desk TV",
			 "FB Cover Photo", "FB Profile Photo", "Twitter Photo",
			 "Instagram Photo", "KnightConnect", "Business Card", "Union TV",
			 "Other"]
		end


		def web_needs
			["New Event Site", "New Org Site", "Re-Brand", "Change Text",
			 "Change Media", "Change Layout", "Change Design", "New Feature",
			 "Other"]
		end


		def video_needs
			["Event Promotion", "Live Production", "Event Recap",
			 "Exec Video", "Reveal / Teaser", "Other"]
		end


		def statuses
			STATUSES[3..7]
		end
	end

	# Returns a list of users who advise the order's organization. This uses the
	# eponymous Organization#advisors.
	#
	def advisors
		organization.advisors
	end

	# Answers whether a given user can read the order. See also the readable scope
	# for the purpose of querying readable orders.
	#
	def readable? user
		readable ||= !owner.nil? && owner == user
		readable ||= !creative.nil? && creative == user
		readable ||= user.role == "Creative" && status == "Unclaimed" && flavor == user.flavor
		readable ||= !organization.nil? && advisors.include?(user)
	end


	def subscribe *users
		self.subscriptions += users.flatten.map { |u| (u.respond_to? :id) ? u.id : u }
		subscriptions.uniq!
		subscriptions.compact!
		save
	end


	def unsubscribe *users
		self.subscriptions -= users.flatten.map { |u| (u.respond_to? :id) ? u.id : u }
		subscriptions.uniq!
		subscriptions.compact!
		save
	end

	# Check the due date for invalid conditions, including due dates less than
	# two weeks away and due dates placed on weekends. Note that this is not
	# currently given as an ActiveRecord validation, as we don't wish to validate
	# changes made by administrators.
	#
	def validate_due_date
		return_value = true

		unless due.present? && due >= Date.today + 2.weeks
			errors.add :due, "date must be at least two weeks away."
			return_value = false
		end

		if due.saturday? || due.sunday?
			errors.add :due, "date shouldn't be on a weekend."
			return_value = false
		end

		return return_value
	end
end
