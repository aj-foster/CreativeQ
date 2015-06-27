class ChangeFlavorToTypeOnOrders < ActiveRecord::Migration
  def up
    Order.all.each do |order|
      case order.flavor
      when "Graphics"
        order.flavor = "GraphicOrder"
      when "Web"
        order.flavor = "WebOrder"
      when "Video"
        order.flavor = "VideoOrder"
      end

      order.save!
    end

    rename_column :orders, :flavor, :type
  end

  def down
    rename_column :orders, :type, :flavor

    Order.all.each do |order|
      case order.flavor
      when "Graphics"
        order.flavor = "GraphicOrder"
      when "Web"
        order.flavor = "WebOrder"
      when "Video"
        order.flavor = "VideoOrder"
      end

      order.save!
    end
  end
end
