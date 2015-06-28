require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  # orders#index

  test "render orders index for users" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:graphic_order, owner: user)
    sign_in user
    get :index
    assert_response :success, "Failed to show orders index to user"
    assert_not_nil assigns(:orders), "Failed to assign orders index listing"
    assert_not_equal [], assigns(:orders), "Failed to populate orders index"
  end

  test "render unclaimed orders listing for creatives" do
    user = FactoryGirl.create(:user, role: "Creative", flavor: "Graphics")
    order = FactoryGirl.create(:graphic_order, status: "Unclaimed")
    sign_in user
    get :index
    assert_response :success, "Failed to list unclaimed orders for creative"
    assert_not_nil assigns(:unclaimed),
      "Failed to assign unclaimed orders listing for creative"
    assert_not_equal [], assigns(:unclaimed),
      "Failed to populate unclaimed orders listing for creative"
  end

  test "render claimed orders listing for creatives" do
    user = FactoryGirl.create(:user, role: "Creative", flavor: "Graphics")
    order = FactoryGirl.create(:graphic_order, status: "Claimed",
      creative: user)
    sign_in user
    get :index
    assert_response :success, "Failed to list claimed orders for creative"
    assert_not_nil assigns(:claimed),
      "Failed to assign claimed orders listing for creative"
    assert_not_equal [], assigns(:claimed),
      "Failed to populate claimed orders listing for creative"
  end

  test "render unapproved orders listing for advisor" do
    user = FactoryGirl.create(:user_advisor)
    order = FactoryGirl.create(:graphic_order, status: "Unapproved",
      organization: user.organizations.first)
    sign_in user
    get :index
    assert_response :success, "Failed to list unapproved orders for advisor"
    assert_not_nil assigns(:unapproved),
      "Failed to assign unapproved orders listing for advisor"
    assert_not_equal [], assigns(:unapproved),
      "Failed to populate unapproved orders listing for advisor"
  end

  test "render unrelated orders listing for admins" do
    user = FactoryGirl.create(:user, role: "Admin")
    order = FactoryGirl.create(:graphic_order, status: "Claimed")
    sign_in user
    get :index
    assert_response :success, "Failed to list unrelated orders for creative"
    assert_not_nil assigns(:orders),
      "Failed to assign unrelated orders listing for creative"
    assert_not_equal [], assigns(:orders),
      "Failed to populate unrelated orders listing for creative"
  end

  test "protect orders index from non-users" do
    get :index
    assert_redirected_to new_user_session_path,
      "Showed orders index to non-user"
  end


  # orders#completed

  test "render completed orders for users" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:graphic_order, owner: user, status: "Complete")
    sign_in user
    get :completed
    assert_response :success, "Failed to show completed orders to user"
    assert_not_nil assigns(:orders), "Failed to assign completed orders listing"
    assert_not_equal [], assigns(:orders), "Failed to populate completed orders"
  end

  test "protect completed orders from non-users" do
    get :completed
    assert_redirected_to new_user_session_path,
      "Showed completed orders to non-user"
  end


  # orders#show

  test "render order for owner" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:graphic_order, owner: user)
    sign_in user
    get :show, {id: order.id}
    assert_response :success, "Failed to show order to its owner"
    assert_not_nil assigns(:order), "Failed to assign order for owner"
  end

  test "render unclaimed order for creative" do
    user = FactoryGirl.create(:user, role: "Creative", flavor: "Graphics")
    order = FactoryGirl.create(:graphic_order, status: "Unclaimed")
    sign_in user
    get :show, {id: order.id}
    assert_response :success, "Failed to show unclaimed order to creative"
    assert_not_nil assigns(:order),
      "Failed to assign unclaimed order for creative"
  end

  test "render claimed order for creative" do
    user = FactoryGirl.create(:user, role: "Creative", flavor: "Graphics")
    order = FactoryGirl.create(:graphic_order, status: "Claimed",
      creative: user)
    sign_in user
    get :show, {id: order.id}
    assert_response :success, "Failed to show claimed order to creative"
    assert_not_nil assigns(:order),
      "Failed to assign claimed order for creative"
  end

  test "render order for advisor" do
    user = FactoryGirl.create(:user_advisor)
    order = FactoryGirl.create(:graphic_order,
      organization: user.organizations.first)
    sign_in user
    get :show, {id: order.id}
    assert_response :success, "Failed to show order to advisor"
    assert_not_nil assigns(:order),
      "Failed to assign order for advisor"
  end

  test "render unrelated order for admin" do
    user = FactoryGirl.create(:user, role: "Admin")
    order = FactoryGirl.create(:graphic_order)
    sign_in user
    get :show, {id: order.id}
    assert_response :success, "Failed to show order to admin"
    assert_not_nil assigns(:order),
      "Failed to assign order for admin"
  end
end