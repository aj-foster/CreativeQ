class AddApprovalsToOrders < ActiveRecord::Migration
  def change
    add_reference :orders, :student_approval, index: true
    add_reference :orders, :advisor_approval, index: true
    add_reference :orders, :final_one, index: true
    add_reference :orders, :final_two, index: true
  end
end
