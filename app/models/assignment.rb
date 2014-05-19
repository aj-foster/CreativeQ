class Assignment < ActiveRecord::Base
	
	belongs_to :user
	belongs_to :organization

	scope :advised, -> { where(role: "Advisor") }
end