require 'test_helper'

class UserTest < ActiveSupport::TestCase

  # Validation Tests
  #

  test "user is valid with all attributes" do
    user = FactoryGirl.build(:user)
    assert user.valid?, "User was not valid with all attributes"
  end

  test "user is invalid without a first name" do
    user = FactoryGirl.build(:user, first_name: "")
    assert_not user.valid?, "User was valid without a first name"
  end

  test "user is invalid without a last name" do
    user = FactoryGirl.build(:user, last_name: "")
    assert_not user.valid?, "User was valid without a last name"
  end

  # Also: User#validate_creative_flavor

  test "creative user is invalid without a flavor" do
    user = FactoryGirl.build(:user, role: "Creative", flavor: "")
    assert_not user.valid?, "Creative user was valid without a flavor"
  end


  # Instance Method Tests
  #

  # User#active_for_authentication?

  test "retired user is not active for authentication" do
    user = FactoryGirl.create(:user, role: "Retired")
    assert_not user.active_for_authentication?,
      "Retired user was active for authentication"
  end

  # User#name

  test "user name contains first and last name" do
    user = FactoryGirl.create(:user, first_name: "Joe", last_name: "Smoe")
    assert_equal "Joe Smoe", user.name,
      "user name did not contain first and last name"
  end

  # User#unlink_orders

  test "user orders have no owner after unlinking" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order, owner: user)
    user.unlink_orders
    order = Order.find(order.id)
    assert_nil order.owner, "User's order had owner after unlinking"
  end
end
