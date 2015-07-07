FactoryGirl.define do

  factory :notification do
    sequence(:title) { |i| "Notification #{i}" }
    message "This longer message for the notification."
    association :user
    association :order
  end
end