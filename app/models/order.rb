class Order < ActiveRecord::Base

	STATUSES = %w[Unapproved Unclaimed Claimed Started Proofing Revising Complete]
	TYPES = %w[Graphic Web Video]
	after_initialize :setup_order

	belongs_to :owner, class_name: 'User'
	belongs_to :creative, class_name: 'User'
	belongs_to :organization


	validates :name, :due, :description, :needs, presence: true


	def validate_due_date
		unless due.present? && due >= Date.today + 2.weeks
			errors.add :due, "date must be at least two weeks away."
		end
	end


	def hsl
		hue = [[(due.to_i - Date.today.to_time.to_i) / 2.weeks.to_i * 100, 100].min, 0].max
		saturation = "100%"
		lightness = "50%"

		return "hsl(" + hue.to_s + ", " + saturation + ", " + lightness + ")"
	end


	def setup_order
		self.status ||= STATUSES[0]
		self.event ||= {}
		self.needs ||= {}
	end
end