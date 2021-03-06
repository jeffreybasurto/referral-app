require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe Agent, type: :model do
  context 'rails validations' do
    it { should belong_to :organisation }
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_inclusion_of(:bank_name).in_array(Agent::BANK_NAMES) }
    it { should validate_presence_of :insurance_company_name }
    it { should validate_inclusion_of(:insurance_company_name).in_array(Agent::INSURANCE_COMPANIES) }
    it { should validate_presence_of :organisation }
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :phone }
    it { should validate_presence_of :dob }
  end

  describe '#generate_agent_id' do
    let!(:new_id) { Devise.friendly_token(10) }
    let(:org) { create :organisation }
    let(:existing_agent) { create :agent, organisation: org }
    let(:existing_id) { existing_agent.agent_id }
    subject { build :agent, organisation: org }

    before { subject.referral_token = 'abcdef' }

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

  describe '#generate_referral_token' do
    let!(:new_token) { Devise.friendly_token(23) }
    let(:org) { create :organisation }
    let(:existing_agent) { create :agent, organisation: org }
    let(:existing_token) { existing_agent.referral_token }
    subject { build :agent, organisation: org }

    before { subject.agent_id = 'abcdef' }

    context 'taken' do
      it 'retries with higher length' do
        expect(Devise).to receive(:friendly_token).with(20).and_return existing_token
        expect(Devise).to receive(:friendly_token).with(21).and_return existing_token
        expect(Devise).to receive(:friendly_token).with(22).and_return existing_token
        allow(Devise).to receive(:friendly_token).with(23).and_return new_token

        expect {
          expect(subject).to be_valid
        }.to change(subject, :referral_token).from(nil).to(new_token)
      end
    end
  end

  describe '#invite_all' do
    subject { create(:agent) }

    it 'sends nothing' do
      assert_performed_jobs 0 do
        subject.invite_all([])
      end
    end

    context 'multiple emails' do
      let(:emails) { %w(test1@test.com test2@test.com test3@test.com) }

      it 'sends multiple invitation emails' do
        expect {
          assert_performed_jobs emails.count do
            subject.invite_all(emails)
          end
        }.to change(ActionMailer::Base.deliveries, :count).by(emails.count)
      end

      it 'creates multiple pending invitations' do
        expect {
          subject.invite_all(emails)
          subject.reload
        }.to change(subject.invitations, :count).by(emails.count)
        expect(subject.invitations.pluck(:email)).to match_array emails
      end
    end
  end

  describe '#gen_ref_token_for_link' do
    subject { create :agent }

    it 'increments ref_generated_count' do
      expect {
        subject.gen_ref_token_for_link
      }.to change(subject, :ref_link_generated_count).from(0).to(1)
    end

    it 'return referral_token' do
      expect(subject.gen_ref_token_for_link).to eq subject.referral_token
    end
  end

  describe '#get_all_children' do
    let(:org) { create :organisation }
    subject { create :agent, organisation: org }
    let!(:child_1) { create :agent, organisation: org, invited_by: subject }
    let!(:child_2) { create :agent, organisation: org, invited_by: subject }
    let!(:child_3) { create :agent, organisation: org, invited_by: subject }
    let!(:child_4) { create :agent, organisation: org, invited_by: subject }
    let!(:child_5) { create :agent, organisation: org, invited_by: subject }
    let!(:child_1_child_1) { create :agent, organisation: org, invited_by: child_1 }
    let!(:child_2_child_1) { create :agent, organisation: org, invited_by: child_1 }
    let!(:child_3_child_1) { create :agent, organisation: org, invited_by: child_1 }
    let!(:child_1_child_2) { create :agent, organisation: org, invited_by: child_2 }
    let!(:child_2_child_2) { create :agent, organisation: org, invited_by: child_2 }

    it 'returns all children' do
      expect(subject.get_all_children.count).to eq 10
      expect(subject.get_all_children).to match_array [child_1, child_2, child_3, child_4, child_5, child_1_child_1, child_2_child_1, child_3_child_1, child_1_child_2, child_2_child_2]
    end
  end
end
