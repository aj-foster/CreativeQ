class Comment < ActiveRecord::Base

	# Relationships

	belongs_to :user
	belongs_to :order

	# Attachment attributes

	has_attached_file :attachment
end