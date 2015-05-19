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
end