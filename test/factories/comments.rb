FactoryGirl.define do

  factory :comment do
    message "Some comment."

    association :user
    association :order
  end
end