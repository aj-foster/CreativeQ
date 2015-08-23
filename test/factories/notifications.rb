FactoryGirl.define do

  factory :notification do
    sequence(:title) { |i| "Notification #{i}" }
    message "This longer message for the notification."
    association :user
    association :notable, factory: :order
  end
end