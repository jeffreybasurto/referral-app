require 'rails_helper'

RSpec.describe Agent, type: :model do
  context 'rails validations' do
    it { should belong_to :organisation }
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :bank_name }
    it { should validate_inclusion_of(:bank_name).in_array(Agent::BANK_NAMES) }
    it { should validate_inclusion_of(:insurance_company_name).in_array(Agent::INSURANCE_COMPANIES) }
    it { should validate_presence_of :organisation }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :phone }
    it { should validate_presence_of :dob }
    it { should validate_presence_of :account_name }
    it { should validate_presence_of :account_number }
    it { should validate_presence_of :branch_name }
  end
end
