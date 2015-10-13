require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'Agents registration', type: :feature do
  let(:sample) { build :agent }
  let(:org) { create(:organisation) }
  let(:agent) { create(:agent, organisation: org) }

  scenario 'Agent sign up with organisation details' do
    org_name = 'New Org'
    visit root_path

    click_link I18n.t('devise.registrations.sign_up')

    fill_in 'organisation[name]', with: org_name
    fill_in 'organisation[agents_attributes][0][email]', with: sample.email
    fill_in 'organisation[agents_attributes][0][password]', with: 'password'
    fill_in 'organisation[agents_attributes][0][password_confirmation]', with: 'password'
    fill_in 'organisation[agents_attributes][0][first_name]', with: sample.first_name
    fill_in 'organisation[agents_attributes][0][last_name]', with: sample.last_name
    fill_in 'organisation[agents_attributes][0][phone]', with: sample.phone
    fill_in 'organisation[agents_attributes][0][dob]', with: sample.dob
    select sample.insurance_company_name, from: 'organisation[agents_attributes][0][insurance_company_name]'
    choose sample.bank_name
    fill_in 'organisation[agents_attributes][0][account_name]', with: sample.account_name
    fill_in 'organisation[agents_attributes][0][account_number]', with: sample.account_number
    fill_in 'organisation[agents_attributes][0][branch_name]', with: sample.branch_name
    fill_in 'organisation[agents_attributes][0][branch_address]', with: sample.branch_address

    expect {
      click_button I18n.t('devise.registrations.sign_up')
    }.to change(Organisation, :count).by(1)

    expect(Organisation.last.name).to eq org_name
    expect(Organisation.last.agents.count).to eq 1

    fill_in 'agent[email]', with: sample.email
    fill_in 'agent[password]', with: 'password'
    click_button I18n.t('devise.sessions.log_in')
    expect(page).to have_content I18n.t('dashboard.greeting', name: sample.name, email: sample.email)
  end


  scenario 'Agent sign up from invite' do
    invite = Agent.invite!({ email: sample.email, organisation: org, skip_invitation: true }, agent)
    visit accept_agent_invitation_url(invitation_token: invite.raw_invitation_token)

    fill_in_common_fields

    expect {
      click_button I18n.t('helpers.submit.agent.update')
    }.to change(org, :invitations_accepted).by(1)
  end

  scenario 'Agent sign up from link' do
    visit new_agent_registration_path(invitation_token: agent.referral_token)

    fill_in 'Email', with: sample.email
    fill_in_common_fields

    expect {
      click_button I18n.t('helpers.submit.agent.create')
    }.to change(org, :agents_via_ref_link).by(1)
  end
end

private
def fill_in_common_fields
  fill_in 'agent[password]', with: 'password'
  fill_in 'agent[password_confirmation]', with: 'password'
  fill_in 'agent[first_name]', with: sample.first_name
  fill_in 'agent[last_name]', with: sample.last_name
  fill_in 'agent[phone]', with: sample.phone
  fill_in 'agent[dob]', with: sample.dob
  select sample.insurance_company_name, from: 'agent[insurance_company_name]'
  choose sample.bank_name
  fill_in 'agent[account_name]', with: sample.account_name
  fill_in 'agent[account_number]', with: sample.account_number
  fill_in 'agent[branch_name]', with: sample.branch_name
  fill_in 'agent[branch_address]', with: sample.branch_address
end
