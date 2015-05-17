class AddSubscriptionsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :subscriptions, :integer, array: true, null: false, default: []
  end
end
