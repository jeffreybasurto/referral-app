FactoryGirl.define do
  factory :agent do
    sequence :email do |n|
      "person#{n}@example.com"
    end
    sequence :first_name do |n|
      "First Name #{n}"
    end
    sequence :last_name do |n|
      "Last Name #{n}"
    end
    phone '+62 21 6539-0605'
    dob 30.years.ago.strftime('%d/%m/%Y')
    bank_name 'Mandiri'
    insurance_company_name 'AIA FINANCIAL'
    account_name 'tester account'
    account_number '123123123123123'
    branch_name 'random bank branch'
    branch_address 'random address'
    organisation { create :organisation }
  end
end