require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'Agent dashboard', type: :feature do
  subject { create(:agent) }
  let(:sample) { build(:organisation) }
  let(:agent_1_params) { build(:agent) }
  let(:agent_2_params) { build(:agent) }
  let!(:agent_1) { Agent.invite!({ email: agent_1_params.email, organisation: subject.organisation, skip_invitation: true }, subject) }
  let!(:agent_2) { Agent.invite!({ email: agent_2_params.email, organisation: subject.organisation, skip_invitation: true }, subject) }
  let!(:agent_3) { create(:agent, organisation: subject.organisation, invited_by_id: subject.id, invited_by_type: subject.class.name) }

  before do
    params = agent_1_params.attributes.symbolize_keys.slice(:bank_name, :insurance_company_name, :first_name, :last_name, :phone, :dob, :account_name, :account_number, :branch_name).merge(invitation_token: agent_1.raw_invitation_token)
    Agent.accept_invitation!(params)

    login_as(subject, :scope => :agent)
    visit root_path
  end

  scenario 'View listing' do
    expect(page).to have_content I18n.t('dashboard.stats.explanation', sign_ups: I18n.t('dashboard.stats.sign_ups', count: subject.invitations_accepted), divider: I18n.t('dashboard.stats.divider'), sent: I18n.t('dashboard.stats.sent', count: subject.unique_mails_sent))

    within 'tbody tr:nth-child(1)' do
      expect(page).to have_content agent_1_params.email
      expect(page).to have_content I18n.t('dashboard.table.headers.invitation_statuses.joined_via_mail')
    end

    within 'tbody tr:nth-child(2)' do
      expect(page).to have_content agent_2_params.email
      expect(page).to have_content I18n.t('dashboard.table.headers.invitation_statuses.pending')
    end

    within 'tbody tr:nth-child(3)' do
      expect(page).to have_content agent_3.email
      expect(page).to have_content I18n.t('dashboard.table.headers.invitation_statuses.joined_via_link')
    end
  end

  scenario 'Send invitations' do
    emails = %w(test1@test.com test2@test.com test3@test.com)
    fill_in 'invitations[emails]', with: emails.join(',')

    expect_any_instance_of(Agent).to receive(:invite_all).with(emails)
    click_button I18n.t('helpers.submit.invitations.submit')
  end

  scenario 'Referral link' do
    expect(page).to have_link(I18n.t('dashboard.referral_link'), href: reveal_referral_token_path(locale: I18n.locale))
    click_link I18n.t('dashboard.referral_link')
    expect(page).to have_content(I18n.t('dashboard.reveal', path: new_agent_registration_url(invitation_token: subject.referral_token, locale: I18n.locale)))
  end
end
