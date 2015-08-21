FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "person#{n}@example.com"
    end
    sequence :name do |n|
      "Name #{n}"
    end
    password '12345678'
    password_confirmation '12345678'
  end
end