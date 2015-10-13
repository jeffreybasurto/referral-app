FactoryGirl.define do
  factory :organisation do
    sequence :name do |n|
      "Organisation ##{n}"
    end
  end
end