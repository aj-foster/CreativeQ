class User < ActiveRecord::Base

	devise :database_authenticatable, :registerable,
		:recoverable, :rememberable, :trackable, :validatable


	has_many :assignments
	has_many :organizations, through: :assignments

	has_many :orders, inverse_of: :owner, foreign_key: 'owner_id'
	has_many :claimed_orders, class_name: 'Order', inverse_of: :creative, foreign_key: 'creative_id'
end