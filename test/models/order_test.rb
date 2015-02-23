require 'test_helper'

class OrderTest < ActiveSupport::TestCase

    # Validation Tests
    
    def test_name_presence_validation
        order_no_name = orders(:order_no_name)
        assert_not order_no_name.save, "Saved order without a name"
    end

    def test_due_date_presence_validation
        order_no_due_date = orders(:order_no_due_date)
        assert_not order_no_due_date.save, "Saved order without a due date"
    end

    def test_description_presence_validation
        order_no_description = orders(:order_no_description)
        assert_not order_no_description.save, "Saved order without a description"
    end

    def test_needs_presence_validation
        order_no_needs = orders(:order_no_needs)
        assert_not order_no_needs.save, "Saved order without needs"
    end
end