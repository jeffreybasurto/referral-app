require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe Organisation, type: :model do
  it { should validate_presence_of :name }
  it { should validate_uniqueness_of :name }
  it { should have_many :agents }
  subject { create :organisation }
  let(:agent) { create(:agent, organisation: subject) }

  describe '#total_gen_ref_token_for_link' do
    it 'gets total ref_generated_count' do
      expect {
        agent.gen_ref_token_for_link
        agent.gen_ref_token_for_link
      }.to change(subject, :total_ref_link_generated_count).from(0).to(2)
    end
  end

  describe '#unique_mails_sent' do
    before do
      invitation = Agent.invite!({ email: 'test@test.com', organisation: subject }, agent)
      Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
      invitation = Agent.invite!({ email: 'test2@test.com', organisation: subject }, agent)
      Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
      subject.agents.create(email: 'test3@test.com', bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
    end

    it 'returns agent invitations' do
      expect(subject.unique_mails_sent).to eq 2
    end
  end

  describe '#mails_sent' do
    before do
      agent.invite_all(['test@test.com'])
      agent.invite_all(['test@test.com'])
    end

    it 'returns agent invitations' do
      expect(subject.total_mails_sent).to eq 2
      expect(subject.unique_mails_sent).to eq 1
    end
  end

  describe '#invitations_accepted' do
    before do
      invitation = Agent.invite!({ email: 'test@test.com', organisation: subject }, agent)
      Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
      invitation = Agent.invite!({ email: 'test2@test.com', organisation: subject }, agent)
      Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
      subject.agents.create(email: 'test3@test.com', bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
    end

    it 'returns agents who accepted invitation' do
      expect(subject.invitations_accepted).to eq 2
    end
  end

  describe '#agents_via_ref_link' do
    before do
      #email invite
      invitation = Agent.invite!({ email: 'test@test.com', organisation: subject }, agent)
      Agent.accept_invitation!(invitation_token: invitation.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch')
      #sign up straight to org
      subject.agents.create(email: 'test2@test.com', bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch', password: 'password', password_confirmation: 'password')
      #sign up with static link
      subject.agents.create(email: 'test3@test.com', bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch', password: 'password', password_confirmation: 'password', invited_by: subject)
    end

    it 'returns agents who signed up from static referral link' do
      expect(subject.agents_via_ref_link).to eq 1
    end
  end
end
