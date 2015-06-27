class AddProgressToOrders < ActiveRecord::Migration
  def up
    add_column :orders, :progress, :string, null: false, default: ""

    progresses = ["Due Date Pending", "Started", "In-Progress", "Proofing",
                  "Revising", "Awaiting Approval"]
    Order.all.each do |order|
      if progresses.include?(order.status)
        order.progress = order.status
        order.status = "Claimed"
        order.save!
      end
    end
  end

  def down
    Order.all.each do |order|
      if order.progress.present?
        order.status = order.progress
        order.save!
      end
    end

    remove_column :orders, :progress
  end
end
