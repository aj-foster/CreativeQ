class Assignment < ActiveRecord::Base

	ROLES = %w[Member Advisor]

	after_initialize :setup_assignment
	
	belongs_to :user
	belongs_to :organization

	scope :advised, -> { where(role: "Advisor") }


	private
		def setup_assignment
			self.role ||= ROLES[0]
		end
end