require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'Agents registration', type: :feature do
  let!(:org) { create(:organisation) }
  let!(:test_org) { create(:organisation, name: 'Test Org', test: true) }
  let(:sample) { build :agent, organisation: org }
  let!(:agent) { create(:agent, organisation: org) }

  scenario 'Agent sign up with new organisation details' do
    org_name = 'New Org'
    visit root_path

    click_link I18n.t('devise.registrations.sign_up')

    fill_in 'agent[organisation_name]', with: org_name
    fill_in 'agent[email]', with: sample.email
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

    expect {
      click_button I18n.t('devise.registrations.sign_up')
    }.to change(Organisation, :count).by(1)

    expect(Organisation.last.name).to eq org_name
    expect(Organisation.last.agents.count).to eq 1

    expect(page).to have_content I18n.t('devise.registrations.signed_up')
    expect(page).to have_content I18n.t('dashboard.greeting', name: sample.name, email: sample.email)
  end

  scenario 'Agent sign up to existing organisation', :js do
    visit root_path

    click_link I18n.t('devise.registrations.sign_up')
    org_name_field = find('#agent_organisation_name').native

    #find test orgs
    org_name_field.send_key test_org.name[0..4]
    sleep(1) #so that the search has time to complete before checking nothing is there
    expect(page).to have_no_css('.ui-menu-item', text: test_org.name)

    #find normal orgs
    fill_in 'agent[organisation_name]', with: '' #clear existing text
    org_name_field.send_key org.name[0..4]
    expect(page).to have_css('.ui-menu-item', text: org.name)
    page.find('.ui-menu-item', text: org.name).click

    fill_in 'agent[email]', with: sample.email
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

    click_button I18n.t('devise.registrations.sign_up')

    expect(Organisation.count).to eq 2
    expect(org.agents.count).to eq 2
    expect(page).to have_content I18n.t('devise.registrations.signed_up')
    expect(page).to have_content I18n.t('dashboard.greeting', name: sample.name, email: sample.email)
  end

  scenario 'Agent sign up from invite' do
    invite = Agent.invite!({ email: sample.email, organisation: org, skip_invitation: true, insurance_company_name: agent.insurance_company_name }, agent)
    visit accept_agent_invitation_url(invitation_token: invite.raw_invitation_token)

    fill_in_common_fields

    expect {
      click_button I18n.t('helpers.submit.agent.update')
    }.to change(org, :invitations_accepted).by(1)
    expect(page).to have_content I18n.t('devise.invitations.updated')
  end

  scenario 'Agent sign up from link' do
    visit new_agent_registration_path(invitation_token: agent.referral_token)

    fill_in 'Email', with: sample.email
    fill_in_common_fields

    expect {
      click_button I18n.t('helpers.submit.agent.create')
    }.to change(org, :agents_via_ref_link).by(1)
    expect(page).to have_content I18n.t('devise.invitations.updated')
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
  choose sample.bank_name
  fill_in 'agent[account_name]', with: sample.account_name
  fill_in 'agent[account_number]', with: sample.account_number
  fill_in 'agent[branch_name]', with: sample.branch_name
  fill_in 'agent[branch_address]', with: sample.branch_address
end
