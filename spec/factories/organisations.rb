FactoryGirl.define do
  factory :organisation do
    sequence :email do |n|
      "organisation#{n}@example.com"
    end
    sequence :name do |n|
      "Organisation ##{n}"
    end
    password '12345678'
    password_confirmation '12345678'
  end
end