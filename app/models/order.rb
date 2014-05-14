class Order < ActiveRecord::Base

	STATUSES = %w[Unapproved Unclaimed Claimed Started Proofing Revising Complete]
	TYPES = %w[Graphic Web Video]
	after_initialize :setup_order

	belongs_to :owner, class_name: 'User'
	belongs_to :creative, class_name: 'User'
	belongs_to :organization


	validates :name, :due, :description, :needs, presence: true
	validate :two_weeks_until_deadline


	def two_weeks_until_deadline
		return if can? :manage, Order

		if !due.present? || due > DateTime.now + 2.weeks
			errors.add :due, "Orders require at least two weeks notice."
		end
	end


	private
		def setup_order
			self.status ||= STATUSES[0]
		end
end