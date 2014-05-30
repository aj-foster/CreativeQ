class Order < ActiveRecord::Base

	STATUSES = %w[Unapproved Unclaimed Claimed Started Proofing Revising Complete]
	TYPES = %w[Graphics Web Video]
	self.per_page = 20

	after_initialize :setup_order

	belongs_to :owner, class_name: 'User'
	belongs_to :creative, class_name: 'User'
	belongs_to :organization


	validates :name, :due, :description, :needs, presence: true

	scope :completed, -> (user) { where(status: "Completed").where("owner_id = ? OR
		creative_id = ? OR organization_id IN (?)", user.id, user.id,
		user.assignments.advised.pluck(&:id)) }

	class << self
		def graphics_needs
			["Handbill", "Poster", "A-Frame", "Banner", "Newspaper", "T-Shirt",
			 "Logo", "Brochure", "Program", "FB Event Photo",
			 "FB Cover Photo", "FB Profile Photo",
			 "KnightConnect", "Business Card", "Union TV"]
		end


		def web_needs
			["New Event Site", "New Org Site", "Re-Brand", "Change Text",
			 "Change Media", "Change Layout", "Change Design", "New Feature",
			 "Other"]
		end


		def video_needs
			["Pre-Event Promo", "Post-Event Promo", "Day of Event",
			 "Live Event", "Other"]
		end


		def statuses
			STATUSES[3..6]
		end
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
		hue = [[(due - Date.today).to_f / 14.0 * 100, 100].min, 0].max
		saturation = "100%"
		lightness = "40%"

		return "hsl(" + hue.to_s + ", " + saturation + ", " + lightness + ")"
	end


	def setup_order
		self.status ||= STATUSES[0]
		self.event ||= {}
		self.needs ||= {}
		# self.flavor ||= "Graphics"
	end
end