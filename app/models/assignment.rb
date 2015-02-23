class Assignment < ActiveRecord::Base

	ROLES = %w[Member Advisor]

	belongs_to :user
	belongs_to :organization

	scope :advised, -> { where(role: "Advisor") }
end