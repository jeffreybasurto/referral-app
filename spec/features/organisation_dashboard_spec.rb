require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'Organisation dashboard', type: :feature do
  subject { create(:organisation) }
  let(:sample) { build(:organisation) }
  let(:agent_1_params) { build(:agent) }
  let(:agent_2_params) { build(:agent) }
  let!(:agent_1) { Agent.invite!({ email: agent_1_params.email, skip_invitation: true }, subject) }
  let!(:agent_2) { Agent.invite!({ email: agent_2_params.email, skip_invitation: true }, subject) }
  let!(:agent_3) { create(:agent, organisation: subject) }

  before do
    params = agent_1_params.attributes.symbolize_keys.slice(:bank_name, :insurance_company_name, :first_name, :last_name, :phone, :dob, :account_name, :account_number, :branch_name).merge(invitation_token: agent_1.raw_invitation_token)
    Agent.accept_invitation!(params)
  end

  scenario 'Organisation sign up' do
    visit root_path

    click_link I18n.t('devise.registrations.sign_up')

    fill_in 'organisation[name]', with: sample.name
    fill_in 'organisation[email]', with: sample.email
    fill_in 'organisation[password]', with: 'password'
    fill_in 'organisation[password_confirmation]', with: 'password'

    expect {
      click_button I18n.t('helpers.submit.organisation.create')
    }.to change(Organisation, :count).by(1)

    click_link I18n.t('devise.sessions.log_out')
    fill_in 'organisation[email]', with: sample.email
    fill_in 'organisation[password]', with: 'password'
    click_button I18n.t('devise.sessions.log_in')
    expect(page).to have_content I18n.t('dashboard.greeting', name: sample.name, email: sample.email)
  end

  scenario 'View listing' do
    login_as(subject, :scope => :organisation)
    visit root_path

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

  let(:emails) { %w(test1@test.com test2@test.com test3@test.com) }

  scenario 'Send invitations' do
    login_as(subject, :scope => :organisation)
    visit root_path

    fill_in 'invitations[emails]', with: emails.join(',')

    expect_any_instance_of(Organisation).to receive(:invite_all).with(emails)
    click_button I18n.t('helpers.submit.invitations.submit')
  end

  scenario 'Referral link' do
    login_as(subject, :scope => :organisation)
    visit root_path

    expect(page).to have_link(I18n.t('dashboard.referral_link'), href: reveal_referral_token_path(locale: I18n.locale))
    click_link I18n.t('dashboard.referral_link')
    expect(page).to have_content(I18n.t('dashboard.reveal', path: new_agent_registration_url(invitation_token: subject.referral_token, locale: I18n.locale)))
  end
end
