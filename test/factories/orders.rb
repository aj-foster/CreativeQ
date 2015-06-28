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

  factory :graphic_order do
    sequence(:name) { |i| "Graphic Order #{i}" }
    sequence(:due) { |i| Date.today + i }
    description "Brief description."
    event { {} }
    needs { {other: "Placeholder"} }

    association :owner, factory: :user
    organization { owner.organizations.first }
  end

  factory :web_order do
    sequence(:name) { |i| "Web Order #{i}" }
    sequence(:due) { |i| Date.today + i }
    description "Brief description."
    event { {} }
    needs { {other: "Placeholder"} }

    association :owner, factory: :user
    organization { owner.organizations.first }
  end

  factory :video_order do
    sequence(:name) { |i| "Video Order #{i}" }
    sequence(:due) { |i| Date.today + i }
    description "Brief description."
    event { {} }
    needs { {other: "Placeholder"} }

    association :owner, factory: :user
    organization { owner.organizations.first }
  end
end