class ChangeOrderToPolymorphicInNotifications < ActiveRecord::Migration
  def change
    rename_column :notifications, :order_id, :notable_id
    add_column :notifications, :notable_type, :string, null: false, default: ""
    add_column :notifications, :link_controller, :string, null: false, default: ""
    add_column :notifications, :link_action, :string, null: false, default: ""
  end
end
