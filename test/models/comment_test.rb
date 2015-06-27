require 'test_helper'

class CommentTest < ActiveSupport::TestCase

  # Instance Method Tests
  #

  # Comment#user

  test "comment returns user if user is present" do
    order = FactoryGirl.create(:order)
    user = FactoryGirl.create(:user)
    comment = FactoryGirl.create(:comment, order: order, user: user)
    assert_equal user, comment.user,
      "Comment does not return its user when the user is present"
  end

  test "comment returns generic user if user not present" do
    order = FactoryGirl.build(:order)
    comment = FactoryGirl.build(:comment, order: order, user: nil)
    assert comment.user.new_record?,
      "Comment returns real user when the user is not present"
  end
end
