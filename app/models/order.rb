class Order < ActiveRecord::Base

	PROGRESSES = ["Due Date Pending", "In-Progress", "Proofing", "Revising",
								"Awaiting Approval"]
	STATUSES = ["Unapproved", "Unclaimed", "Claimed", "Complete"]
	TYPES = %w[Graphics Web Video]
	self.per_page = 20

	belongs_to :owner, class_name: 'User'
	belongs_to :creative, class_name: 'User'
	belongs_to :organization

	has_many :comments, dependent: :destroy
	has_many :notifications, dependent: :destroy


	validates :name, :due, :description, :needs, presence: true

	scope :readable, -> (user) {
		if user.role == "Creative"
			orders = Order.arel_table
			related = orders[:status].in(["Unclaimed", "Claimed"])
								.and(orders[:type].eq(user.flavor.singularize + "Order"))
			where(
				_owned_by(user)
				.or(_claimed_by(user))
				.or(_advised_by(user))
				.or(related)
			)

		elsif user.role == "Admin"
			all

		else
			where(
				_owned_by(user)
				.or(_claimed_by(user))
				.or(_advised_by(user))
			)
		end
	}

	scope :owned_by, -> (user) { where(self._owned_by(user)) }
	scope :claimed_by, -> (user) { where(self._claimed_by(user)) }
	scope :claimable_by, -> (user) { where(self._claimable_by(user)) }
	scope :advised_by, -> (user) { where(self._advised_by(user)) }

	scope :completed, -> (user) {
		if user.role == "Admin"
			where(status: "Complete")
		else
			where(
				_owned_by(user)
				.or(_claimed_by(user))
				.or(_advised_by(user))
			).where(status: "Complete")
		end
	}

	# In subclasses, this method returns a list of the available needs (things
	# an order could require). Not implemented for generic orders.
	#
	def self.needs
		raise "Error: Abstract class."
	end

	def flavor
		""
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
		readable ||= user.role == "Creative" &&
								 (status == "Unclaimed" || status == "Claimed") &&
								 flavor == user.flavor
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


	private

	def self._owned_by (user)
		self.arel_table[:owner_id].eq(user.id)
	end

	def self._claimed_by (user)
		self.arel_table[:creative_id].eq(user.id)
	end

	def self._claimable_by (user)
		if user.role == "Admin"
			self.arel_table[:status].eq("Unclaimed")
		elsif user.role == "Creative"
			orders = self.arel_table
			orders[:status].eq("Unclaimed")
				.and(orders[:type].eq(user.flavor.singularize + "Order"))
		else
			"0=1"
		end
	end

	def self._advised_by (user)
		if user.role == "Admin"
			"1=1"
		else
			self.arel_table[:organization_id]
					.in(user.assignments.advised.pluck(:organization_id))
		end
	end
end