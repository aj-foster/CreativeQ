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

  test "protect unrelated order from user" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:graphic_order)
    sign_in user
    get :show, {id: order.id}
    assert_redirected_to orders_path, "Showed order to an unrelated user"
  end

  # orders#new

  test "render new order form for users" do
    user = FactoryGirl.create(:user, role: "Basic")
    sign_in user
    get :new
    assert_response :success, "Failed to show new order form to user"
  end

  test "protect new order form from unapproved users" do
    user = FactoryGirl.create(:user, role: "Unapproved")
    sign_in user
    get :new
    assert_redirected_to orders_path, "Showed new order form to unapproved user"
  end

  test "protect new order form from non-users" do
    get :new
    assert_redirected_to new_user_session_path,
      "Showed new order form to non-user"
  end

  # orders#create

  test "create new order for users" do
    user = FactoryGirl.create(:user, role: "Basic")
    sign_in user
    assert_difference "Order.count", 1, "Failed to create order for user" do
      put :create, order: FactoryGirl.attributes_for(:order, organization_id:
        user.organizations.first.id).merge({flavor: "Graphics"})
    end
  end

  test "protect order creation from unapproved users" do
    user = FactoryGirl.create(:user, role: "Unapproved")
    sign_in user
    assert_difference "Order.count", 0, "Created order for unapproved user" do
      put :create, order: FactoryGirl.attributes_for(:order, organization_id:
        user.organizations.first.id).merge({flavor: "Graphics"})
    end
    assert_redirected_to orders_path,
      "Failed to redirect unapproved user during order creation"
  end

  test "protect order creation from non-users" do
    organization = FactoryGirl.create(:organization)
    assert_difference "Order.count", 0, "Created order for non-user" do
      put :create, order: FactoryGirl.attributes_for(:order, organization_id:
        organization.id).merge({flavor: "Graphics"})
    end
    assert_redirected_to new_user_session_path,
      "Failed to redirect non-user during order creation"
  end

  # orders#edit

  test "render edit order form for owner" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:graphic_order, owner: user)
    sign_in user
    get :edit, {id: order.id}
    assert_response :success, "Failed to show edit order form to its owner"
    assert_not_nil assigns(:order),
      "Failed to assign order for editing by its owner"
  end

  test "render edit order form for advisor" do
    user = FactoryGirl.create(:user_advisor)
    order = FactoryGirl.create(:graphic_order,
      organization: user.organizations.first)
    sign_in user
    get :edit, {id: order.id}
    assert_response :success, "Failed to show edit order form to advisor"
    assert_not_nil assigns(:order),
      "Failed to assign order for editing by advisor"
  end

  test "render unrelated edit order form for admin" do
    user = FactoryGirl.create(:user, role: "Admin")
    order = FactoryGirl.create(:graphic_order)
    sign_in user
    get :edit, {id: order.id}
    assert_response :success, "Failed to show edit order form to admin"
    assert_not_nil assigns(:order),
      "Failed to assign order for admin"
  end

  test "protect unrelated edit order from from user" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:graphic_order)
    sign_in user
    get :edit, {id: order.id}
    assert_redirected_to order_path(order),
      "Showed edit order form to an unrelated user"
  end

  test "protect edit order form from non-users" do
    order = FactoryGirl.create(:graphic_order)
    get :edit, {id: order.id}
    assert_redirected_to new_user_session_path,
      "Showed edit order form to non-user"
  end

  # orders#update

  test "update order for owner" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:graphic_order, owner: user)
    sign_in user
    patch :update, id: order.id, order: {description: "New description"}
    assert_redirected_to order_path(order),
      "Failed to redirect order owner after update"
    assert_equal "New description", Order.find(order.id).description,
      "Failed to update order for its owner"
  end

  test "update order for advisor" do
    user = FactoryGirl.create(:user_advisor)
    order = FactoryGirl.create(:graphic_order,
      organization: user.organizations.first)
    sign_in user
    patch :update, id: order.id, order: {description: "New description"}
    assert_redirected_to order_path(order),
      "Failed to redirect order advisor after update"
    assert_equal "New description", Order.find(order.id).description,
      "Failed to update order for its advisor"
  end

  test "update unrelated order for admin" do
    user = FactoryGirl.create(:user, role: "Admin")
    order = FactoryGirl.create(:graphic_order)
    sign_in user
    patch :update, id: order.id, order: {description: "New description"}
    assert_redirected_to order_path(order),
      "Failed to redirect admin after order update"
    assert_equal "New description", Order.find(order.id).description,
      "Failed to update order for an admin"
  end

  test "protect unrelated order from update by user" do
    user = FactoryGirl.create(:user)
    order = FactoryGirl.create(:graphic_order)
    sign_in user
    patch :update, id: order.id, order: {description: "New description"}
    assert_redirected_to order_path(order),
      "Failed to redirect user before updating unrelated order"
    assert_not_equal "New description", Order.find(order.id).description,
      "Updated unrelated order for user"
  end

  test "protect order update from non-user" do
    order = FactoryGirl.create(:graphic_order)
    patch :update, id: order.id, order: {description: "New description"}
    assert_redirected_to new_user_session_path,
      "Failed to redirect non-user before order update"
    assert_not_equal "New description", Order.find(order.id).description,
      "Updated order for non-user"
  end
end