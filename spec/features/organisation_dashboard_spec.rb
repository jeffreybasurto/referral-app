require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'Organisation dashboard', type: :feature do
  subject { create(:organisation) }
  let(:sample) { build(:organisation) }
  let(:agent_1_params) { build(:agent) }
  let(:agent_2_params) { build(:agent) }
  let!(:agent_1) { Agent.invite!({ email: agent_1_params.email, skip_invitation: true }, subject) }
  let!(:agent_2) { Agent.invite!({ email: agent_2_params.email, skip_invitation: true }, subject) }

  before do
    params = agent_1_params.attributes.symbolize_keys.slice(:bank_name, :insurance_company_name, :first_name, :last_name, :phone, :dob, :account_name, :account_number, :branch_name).merge(invitation_token: agent_1.raw_invitation_token)
    Agent.accept_invitation!(params)
  end

  scenario 'Organisation sign up' do
    visit root_path

    click_link I18n.t('devise.registrations.sign_up_link')

    fill_in 'Email', with: sample.email
    fill_in 'Name', with: sample.name
    fill_in 'organisation[password]', with: 'password'
    fill_in 'organisation[password_confirmation]', with: 'password'


    expect {
      click_button 'Sign up'
    }.to change(Organisation, :count).by(1)

    click_link 'Sign out'
    fill_in 'Email', with: sample.email
    fill_in 'Password', with: 'password'
    click_button 'Log in'
    expect(page).to have_content "Hello #{sample.name} (#{sample.email})."
  end

  scenario 'View listing' do
    login_as(subject, :scope => :organisation)
    visit root_path

    within 'tbody tr:nth-child(1)' do
      expect(page).to have_content agent_1_params.email
      expect(page).to have_content 'Joined.'
    end

    within 'tbody tr:nth-child(2)' do
      expect(page).to have_content agent_2_params.email
      expect(page).to have_content 'Pending.'
    end
  end

  let(:emails) { %w(test1@test.com test2@test.com test3@test.com) }

  scenario 'Send invitations' do
    login_as(subject, :scope => :organisation)
    visit root_path

    fill_in 'Emails', with: emails.join(',')

    expect_any_instance_of(Organisation).to receive(:invite_all).with(emails)
    click_button 'Send invitations'
  end
end
