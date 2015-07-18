require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  # notifications#index

  test "render notifications index for users" do
    user = FactoryGirl.create(:user)
    notification = FactoryGirl.create(:notification, user: user)
    sign_in user
    get :index
    assert_response :success, "Failed to show notifications index to user"
    assert_not_nil assigns(:notifications),
      "Failed to assign notifications index listing"
    assert_not_equal [], assigns(:notifications),
      "Failed to populate notifications index"
  end

  test "protect notifications index from non-users" do
    get :index
    assert_redirected_to new_user_session_path,
      "Showed notifications index to non-user"
  end

  # notifications#read

  test "mark notification as read for user" do
    user = FactoryGirl.create(:user)
    notification = FactoryGirl.create(:notification, user: user)
    sign_in user
    put :read, id: notification.id
    assert_redirected_to notifications_path,
      "Failed to redirect user after notification read"
    assert Notification.find(notification.id).read?,
      "Failed to mark notification as read"
  end

  test "protect notification status from other user" do
    user = FactoryGirl.create(:user)
    notification = FactoryGirl.create(:notification)
    sign_in user
    put :read, id: notification.id
    assert_redirected_to notifications_path,
      "Failed to redirect user after protecting notification status"
    assert_not Notification.find(notification.id).read?,
      "Failed protect notification status from other user"
  end

  test "protect notification status from non-users" do
    notification = FactoryGirl.create(:notification)
    put :read, id: notification.id
    assert_redirected_to new_user_session_path,
      "Failed to protect notification status from non-user"
    assert_not Notification.find(notification.id).read?,
      "Failed protect notification status from non-user"
  end

  # notification#destroy

  test "destroy notification for user" do
    user = FactoryGirl.create(:user)
    notification = FactoryGirl.create(:notification, user: user)
    sign_in user
    assert_difference('Notification.count', -1) do
      delete :destroy, id: notification.id
    end
    assert_redirected_to notifications_path,
      "Failed to redirect user after notification destruction"
  end

  test "protect notification destruction from other user" do
    user = FactoryGirl.create(:user)
    notification = FactoryGirl.create(:notification)
    sign_in user
    assert_difference('Notification.count', 0) do
      delete :destroy, id: notification.id
    end
    assert_redirected_to notifications_path,
      "Failed to redirect user after protecting notification destruction"
  end

  test "protect notification destruction from non-users" do
    notification = FactoryGirl.create(:notification)
    assert_difference('Notification.count', 0) do
      delete :destroy, id: notification.id
    end
    assert_redirected_to new_user_session_path,
      "Failed to protect notification destruction from non-user"
  end

  # notification#view_and_destroy

  test "view and destroy notification for user" do
    user = FactoryGirl.create(:user)
    notification = FactoryGirl.create(:notification, user: user)
    sign_in user
    assert_difference('user.notifications.count', -1) do
      delete :view_and_destroy, id: notification.id
    end
    assert_redirected_to order_path(notification.order),
      "Failed to redirect user after notification destruction"
  end

  test "protect notification viewing and destruction from other user" do
    user = FactoryGirl.create(:user)
    notification = FactoryGirl.create(:notification)
    sign_in user
    assert_difference('user.notifications.count', 0) do
      delete :view_and_destroy, id: notification.id
    end
    assert_redirected_to notifications_path,
      "Failed to redirect user after protecting notification destruction"
  end

  test "protect notification viewing and destruction from non-users" do
    notification = FactoryGirl.create(:notification)
    assert_difference('Notification.count', 0) do
      delete :view_and_destroy, id: notification.id
    end
    assert_redirected_to new_user_session_path,
      "Failed to protect notification destruction from non-user"
  end
end