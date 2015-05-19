FactoryGirl.define do

  factory :assignment do
    association :user
    association :organization
    role "Member"
  end
end