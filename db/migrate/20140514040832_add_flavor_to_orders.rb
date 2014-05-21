class AddFlavorToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :flavor, :string
  end
end
