require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'Agents registration', type: :feature do
  let(:sample) { build :agent }
  let(:org) { create(:organisation) }

  scenario 'Agent sign up from invite' do
    invite = Agent.invite!({ email: sample.email, skip_invitation: true }, org)
    visit accept_agent_invitation_url(invitation_token: invite.raw_invitation_token)

    fill_in_common_fields

    expect {
      click_button I18n.t('helpers.submit.agent.update')
    }.to change(Agent.invitation_accepted, :count).by(1)
  end

  scenario 'Agent sign up from link' do
    visit new_agent_path(invitation_token: org.referral_token)

    fill_in 'Email', with: sample.email
    fill_in_common_fields

    expect_any_instance_of(Agent).to receive(:send_intro_email)
    expect {
      click_button I18n.t('helpers.submit.agent.create')
    }.to change(Agent.invitation_accepted, :count).by(1)
  end
end

def fill_in_common_fields
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
