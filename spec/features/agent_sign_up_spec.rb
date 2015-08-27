require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'Agents registration', type: :feature do
  let(:sample) { build :agent }
  let(:org) { create(:organisation) }

  scenario 'Agent sign up from invite' do
    invite = Agent.invite!({ email: sample.email, skip_invitation: true }, org)
    visit accept_agent_invitation_url(invitation_token: invite.raw_invitation_token)

    fill_in 'First name', with: sample.first_name
    fill_in 'Last name', with: sample.last_name
    fill_in 'Phone number', with: sample.phone
    fill_in 'Date of birth', with: sample.dob
    select sample.insurance_company_name, from: 'Insurance company'
    choose sample.bank_name
    fill_in 'Account name', with: sample.account_name
    fill_in 'Account number', with: sample.account_number
    fill_in 'agent[branch_name]', with: sample.branch_name
    fill_in 'agent[branch_address]', with: sample.branch_address

    expect {
      click_button I18n.t('devise.invitations.edit.submit_button')
    }.to change(Agent.invitation_accepted, :count).by(1)
  end
end
