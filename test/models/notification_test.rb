require 'test_helper'

class NotificationTest < ActiveSupport::TestCase

  # Validation Tests
  #

  test "notification is valid with all attributes" do
    notification = FactoryGirl.build(:notification)
    assert notification.valid? "Notification was not valid with all attributes"
  end

  test "notification is invalid without a title" do
    notification = FactoryGirl.build(:notification, title: "")
    assert_not notification.valid?, "Notification was valid without a title"
  end

  test "notification is invalid without a message" do
    notification = FactoryGirl.build(:notification, message: "")
    assert_not notification.valid?, "Notification was valid without a message"
  end

  test "notification is invalid without a user" do
    notification = FactoryGirl.build(:notification, user: nil)
    assert_not notification.valid?, "Notification was valid without a user"
  end

  test "notification is invalid without an order" do
    notification = FactoryGirl.build(:notification, order: nil)
    assert_not notification.valid?, "Notification was valid without an order"
  end


  # Instance Method Tests
  #

  # Notification#mark_as_read

  test "notification is unread by default" do
    notification = FactoryGirl.create(:notification)
    assert_not Notification.find(notification.id).read?,
      "Notification was not unread by default"
  end

  test "notification is marked as read" do
    notification = FactoryGirl.create(:notification)
    notification.mark_as_read
    assert Notification.find(notification.id).read?,
      "Notification was not marked as read"
  end
end