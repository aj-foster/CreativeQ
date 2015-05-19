FactoryGirl.define do

  factory :order do
    sequence(:name) { |i| "Order #{i}" }
    sequence(:due) { |i| Date.today + i }
    description "Brief description."
    event { {} }
    needs { {other: "Placeholder"} }

    association :owner, factory: :user
    organization { owner.organizations.first }
  end
end