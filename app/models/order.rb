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


	def advisors
		organization.advisors
	end


	def readable? user
		readable ||= !owner.nil? && owner == user
		readable ||= !creative.nil? && creative == user
		readable ||= user.role == "Creative" && status == "Unclaimed" && flavor == user.flavor
		readable ||= !organization.nil? &&
			organization_id.in?(user.assignments.advised.pluck(:organization_id))
	end


	def subscribe *users
		self.subscriptions += users.map { |u| (u.respond_to? :id) ? u.id : u }
		subscriptions.uniq!
		subscriptions.compact!
		save
	end


	def unsubscribe *users
		self.subscriptions -= users.map { |u| (u.respond_to? :id) ? u.id : u }
		subscriptions.uniq!
		subscriptions.compact!
		save
	end


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


	def due_date
		return due.strftime("%A, %B #{due.day.ordinalize}")
	end


	def hsl
		hue = [[(due - Date.today).to_f / 14.0 * 75 + 25, 100].min, 25].max
		saturation = "100%"
		lightness = "#{50.0 - 10 * (hue - 50).abs / 50.0}%"

		return "hsl(" + hue.to_s + ", " + saturation + ", " + lightness + ")"
	end
end
