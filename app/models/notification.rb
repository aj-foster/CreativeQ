class Notification < ActiveRecord::Base

  belongs_to :user
  belongs_to :order

  validates :title, :message, :user, :order, presence: true

  # Marks an order as "read" using its status field.
  #
  def mark_as_read
    self.update(read: true)
  end
end
