class Organization < ActiveRecord::Base

	has_many :assignments
	has_many :users, through: :assignments

	has_many :orders
end