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
  end

  describe '#generate_agent_id' do
    let!(:org) { create :organisation }
    let(:existing_agent) { create :agent, organisation: org }
    let(:existing_id) { existing_agent.agent_id }
    let!(:new_id) { Devise.friendly_token(10) }
    subject { build :agent, organisation: org }

    context 'taken' do
      it 'retries with higher length' do
        expect(Devise).to receive(:friendly_token).with(6).and_return existing_id
        expect(Devise).to receive(:friendly_token).with(7).and_return existing_id
        expect(Devise).to receive(:friendly_token).with(8).and_return existing_id
        expect(Devise).to receive(:friendly_token).with(9).and_return existing_id
        allow(Devise).to receive(:friendly_token).with(10).and_return new_id

        expect {
          expect(subject).to be_valid
        }.to change(subject, :agent_id).from(nil).to(new_id)
      end
    end
  end

end
