class Comment < ActiveRecord::Base

	# Relationships

	belongs_to :user
	belongs_to :order

	# Attachment attributes

	has_attached_file :attachment
	do_not_validate_attachment_file_type :attachment

end