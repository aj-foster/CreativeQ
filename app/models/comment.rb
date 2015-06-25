class Comment < ActiveRecord::Base

	# Relationships

	belongs_to :user
	belongs_to :order

	# Attachment attributes

	has_attached_file :attachment
	do_not_validate_attachment_file_type :attachment

  # For system-generated comments, we need a system user.

  alias_method :default_user, :user

  def user
    default_user || User.new(first_name: "[CreativeQ]", last_name: "")
  end

end