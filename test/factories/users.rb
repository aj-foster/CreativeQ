FactoryGirl.define do

  factory :user do
    first_name "User"
    sequence(:last_name) { |i| "#{i}" }
    sequence(:email) { |i| "user#{i}@test.app" }
    password "Some secret password"
    role "Unapproved"
    phone "(407) 882-1010"

    after(:create) do |user|
      user.assignments << FactoryGirl.create(:assignment, user: user,
        role: "Member")
    end

    factory :user_advisor do
      after(:create) do |user|
        user.assignments.each do |assign|
          assign.update(role: "Advisor")
        end
      end
    end
  end
end