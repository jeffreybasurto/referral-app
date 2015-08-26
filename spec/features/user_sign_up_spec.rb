require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'User registration', type: :feature do
  let(:sample) { build :user }

  scenario 'User sign up' do
    visit root_path

    click_link 'Sign up'

    fill_in 'Email', with: sample.email
    fill_in 'Name', with: sample.name
    fill_in 'user[password]', with: 'password'
    fill_in 'user[password_confirmation]', with: 'password'
    expect {
      click_button 'Sign up'
    }.to change(User, :count).by(1)

    click_link 'Sign out'
    fill_in 'Email', with: sample.email
    fill_in 'Password', with: 'password'
    click_button 'Log in'
    expect(page).to have_content "Hello #{sample.name} (#{sample.email}). Your DocDoc agent ID is #{User.last.docdoc_agent_id}"
  end

  let(:user) { create(:user) }

  scenario 'Agent sign up from invite' do
    invite = User.invite!({ email: sample.email, skip_invitation: true }, user)
    visit accept_user_invitation_url(invitation_token: invite.raw_invitation_token)

    fill_in 'Name', with: sample.name
    fill_in 'user[password]', with: 'password'
    fill_in 'user[password_confirmation]', with: 'password'
    expect {
      click_button I18n.t('devise.invitations.edit.submit_button')
    }.to change(User.invitation_accepted, :count).by(1)

    click_link 'Sign out'
    fill_in 'Email', with: sample.email
    fill_in 'Password', with: 'password'
    click_button 'Log in'
    expect(page).to have_content "Hello #{sample.name} (#{sample.email}). Your DocDoc agent ID is #{User.last.docdoc_agent_id}"
  end
end
