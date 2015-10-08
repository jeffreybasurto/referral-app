require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe Organisation, type: :model do
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of :email }
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should have_many :agents }

  describe '#invite_all' do
    subject { create(:organisation) }

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
        }.to change(subject.agents, :count).by(emails.count)
        expect(subject.agents.pluck(:email)).to match_array emails
      end
    end
  end

  describe '#gen_ref_token_for_link' do
    subject { create :organisation }

    it 'increments ref_generated_count' do
      expect {
        subject.gen_ref_token_for_link
      }.to change(subject, :ref_link_generated_count).from(0).to(1)
    end

    it 'return referral_token' do
      expect(subject.gen_ref_token_for_link).to eq subject.referral_token
    end
  end

  describe '#unique_mails_sent' do
    subject { create :organisation }

    before do
      invitation = Agent.invite!({ email: 'test@test.com' }, subject)
      Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
      invitation = Agent.invite!({ email: 'test2@test.com' }, subject)
      Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
      subject.agents.create(email: 'test3@test.com', bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
    end

    it 'returns agent invitations' do
      expect(subject.unique_mails_sent).to eq 2
    end
  end

  describe '#mails_sent' do
    subject { create :organisation }

    before do
      subject.invite_all(['test@test.com'])
      subject.invite_all(['test@test.com'])
    end

    it 'returns agent invitations' do
      expect(subject.mails_sent).to eq 2
      expect(subject.unique_mails_sent).to eq 1
    end
  end

  describe '#invitations_accepted' do
    subject { create :organisation }

    before do
      invitation = Agent.invite!({ email: 'test@test.com' }, subject)
      Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
      invitation = Agent.invite!({ email: 'test2@test.com' }, subject)
      Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
      subject.agents.create(email: 'test3@test.com', bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
    end

    it 'returns agents who accepted invitation' do
      expect(subject.invitations_accepted).to eq 2
    end
  end

  describe '#agents_via_ref_link' do
    subject { create :organisation }

    before do
      invitation = Agent.invite!({ email: 'test@test.com' }, subject)
      Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
      subject.agents.create(email: 'test2@test.com', bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch', password: 'password', password_confirmation: 'password')
      subject.agents.create(email: 'test3@test.com', bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch', password: 'password', password_confirmation: 'password')
    end

    it 'returns agents who signed up from static referral link' do
      expect(subject.agents_via_ref_link).to eq 2
    end
  end
end
