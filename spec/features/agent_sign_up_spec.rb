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
  fill_in I18n.t('simple_form.labels.defaults.first_name'), with: sample.first_name
  fill_in I18n.t('simple_form.labels.defaults.last_name'), with: sample.last_name
  fill_in I18n.t('simple_form.labels.defaults.phone'), with: sample.phone
  fill_in I18n.t('simple_form.labels.defaults.dob'), with: sample.dob
  select sample.insurance_company_name, from: I18n.t('simple_form.labels.defaults.insurance_company_name')
  choose sample.bank_name
  fill_in I18n.t('simple_form.labels.defaults.account_name'), with: sample.account_name
  fill_in I18n.t('simple_form.labels.defaults.account_number'), with: sample.account_number
  fill_in I18n.t('simple_form.labels.defaults.branch_name'), with: sample.branch_name
  fill_in I18n.t('simple_form.labels.defaults.branch_address'), with: sample.branch_address
end
