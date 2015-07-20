require 'test_helper'

class OrderTest < ActiveSupport::TestCase

  # Validation Tests
  #

  test "order is valid with all attributes" do
    order = FactoryGirl.build(:order)
    assert order.valid?, "Order was not valid with all attributes"
  end
  
  test "order is invalid without a name" do
    order = FactoryGirl.build(:order, name: nil)
    assert_not order.valid?, "Order was valid without a name"
  end
  
  test "order is invalid without a due date" do
    order = FactoryGirl.build(:order, due: nil)
    assert_not order.valid?, "Order was valid without a due date"
  end
  
  test "order is invalid without a description" do
    order = FactoryGirl.build(:order, description: nil)
    assert_not order.valid?, "Order was valid without a description"
  end
  
  test "order is invalid without needs" do
    order = FactoryGirl.build(:order, needs: nil)
    assert_not order.valid?, "Order was valid without needs"
  end


  # Instance Method Tests
  #

  # Order#readable, Order#readable?

  test "order is readable by its owner" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order, owner: user)
    assert Order.readable(user).include?(order),
      "Order was not shown to its owner"
    assert order.readable?(user), "Order was not readable by its owner"
  end

  test "order is readable by its creative" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order, creative: user)
    assert Order.readable(user).include?(order),
      "Order was not shown to its creative"
    assert order.readable?(user), "Order was not readable by its creative"
  end

  test "unclaimed order is readable by a creative of the correct flavor" do
    user = FactoryGirl.create(:user, role: "Creative", flavor: "Graphics")
    order = FactoryGirl.create(:graphic_order, status: "Unclaimed")
    assert Order.readable(user).include?(order),
      "Unclaimed order was not shown to a creative of the correct flavor"
    assert order.readable?(user),
      "Unclaimed order was not readable by a creative of the correct flavor"
  end

  test "unclaimed order is not readable by a creative of an incorrect flavor" do
    user = FactoryGirl.create(:user, role: "Creative", flavor: "Graphics")
    order = FactoryGirl.create(:web_order, status: "Unclaimed")
    assert_not Order.readable(user).include?(order),
      "Unclaimed order was shown to a creative of an incorrect flavor"
    assert_not order.readable?(user),
      "Unclaimed order was readable by a creative of an incorrect flavor"
  end

  test "claimed order is readable by a creative of the correct flavor" do
    user = FactoryGirl.create(:user, role: "Creative", flavor: "Graphics")
    creative = FactoryGirl.create(:user, role: "Creative", flavor: "Graphics")
    order = FactoryGirl.create(:graphic_order, status: "Claimed",
      creative: creative)
    assert Order.readable(user).include?(order),
      "Claimed order was not shown to a creative of the correct flavor"
    assert order.readable?(user),
      "Claimed order was not readable by a creative of the correct flavor"
  end

  test "claimed order is not readable by a creative of an incorrect flavor" do
    user = FactoryGirl.create(:user, role: "Creative", flavor: "Graphics")
    creative = FactoryGirl.create(:user, role: "Creative", flavor: "Web")
    order = FactoryGirl.create(:web_order, status: "Claimed",
      creative: creative)
    assert_not Order.readable(user).include?(order),
      "Claimed order was shown to a creative of an incorrect flavor"
    assert_not order.readable?(user),
      "Claimed order was readable by a creative of an incorrect flavor"
  end

  test "order is readable by an advisor" do
    user = FactoryGirl.create(:user_advisor)
    order = FactoryGirl.create(:order, organization: user.organizations.first)
    assert Order.readable(user).include?(order),
      "Order was not shown to an advisor"
    assert order.readable?(user), "Order was not readable by an advisor"
  end

  test "order is not readable by an unrelated user" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order)
    assert_not Order.readable(user).include?(order),
      "Order was shown to an unrelated user"
    assert_not order.readable?(user), "Order was readable by an unrelated user"
  end


  # Order#subscribe

  test "subscribe adds single user to subscriptions" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order)
    order.subscribe user
    assert order.subscriptions.include?(user.id),
      "Subscribe did not add user to subscriptions"
  end

  test "subscribe adds multiple users to subscriptions" do
    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order)
    order.subscribe user1, user2
    assert [user1.id, user2.id].sort == order.subscriptions.sort,
      "Subscribe did not add multiple users to subscriptions"
  end

  test "subscribe does not duplicate users in subscriptions" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order)
    2.times { order.subscribe user }
    assert_equal 1, order.subscriptions.count(user.id),
      "Subscribe duplicated user in subscriptions"
  end


  # Order#unsubscribe

  test "unsubscribe removes single user from subscriptions" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order, subscriptions: [user.id])
    order.unsubscribe user
    assert_not order.subscriptions.include?(user.id),
      "Unsubscribe did not remove single user from subscriptions"
  end

  test "unsubscribe removes multiple users from subscriptions" do
    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order, subscriptions: [user1.id, user2.id])
    order.unsubscribe user1, user2
    assert order.subscriptions.empty?,
      "Unsubscribe did not remove multiple users from subscriptions"
  end


  # Order#validate_due_date

  test "order is invalid with due date on a Saturday" do
    date = Date.today
    date = date - date.wday - 1 + 3.weeks
    order = FactoryGirl.build(:order, due: date)
    assert_not order.validate_due_date,
      "Order was valid with due date on a Saturday"
  end

  test "order is invalid with due date on a Sunday" do
    date = Date.today
    date = date - date.wday + 3.weeks
    order = FactoryGirl.build(:order, due: date)
    assert_not order.validate_due_date,
      "Order was valid with due date on a Sunday"
  end

  test "order is invalid with a due date less than two weeks away" do
    date = Date.today + 13.days
    date = date - 2.days if date.saturday? || date.sunday?
    order = FactoryGirl.build(:order, due: date)
    assert_not order.validate_due_date, "Order was valid with short due date"
  end

  test "order is valid with valid due date" do
    date = Date.today
    date = date - date.wday + 1.day + 3.weeks
    order = FactoryGirl.build(:order, due: date)
    assert order.validate_due_date, "Order was invalid with valid due date"
  end


  # Order#completed

  test "completed order is readable by its owner" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order, owner: user, status: "Complete")
    assert Order.completed(user).include?(order),
      "Completed order was not shown to its owner"
  end

  test "completed order is readable by its creative" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order, creative: user, status: "Complete")
    assert Order.completed(user).include?(order),
      "Completed order was not shown to its creative"
  end

  test "completed order is readable by an advisor" do
    user = FactoryGirl.create(:user_advisor)
    order = FactoryGirl.create(:order, organization: user.organizations.first,
      status: "Complete")
    assert Order.completed(user).include?(order),
      "Completed order was not shown to an advisor"
  end

  test "completed order is not readable by an unrelated user" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:order)
    assert_not Order.completed(user).include?(order),
      "Completed order was shown to an unrelated user"
  end
end