require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'User dashboard', type: :feature do
  subject { create(:user) }
  let(:new_user_1_email) { build(:user).email }
  let(:new_user_2_email) { build(:user).email }
  let!(:invited_user_1) { User.invite!({ email: new_user_1_email, skip_invitation: true }, subject) }
  let!(:invited_user_2) { User.invite!({ email: new_user_2_email, skip_invitation: true }, subject) }

  before do
    User.accept_invitation!(invitation_token: invited_user_1.raw_invitation_token, name: 'Tester', password: 'abcdef123', password_confirmation: 'abcdef123')
    login_as(subject, :scope => :user)
  end

  scenario 'View listing' do
    visit root_path

    expect(page).to have_content subject.docdoc_agent_id

    within 'tbody tr:nth-child(1)' do
      expect(page).to have_content new_user_1_email
      expect(page).to have_content 'Joined.'
    end

    within 'tbody tr:nth-child(2)' do
      expect(page).to have_content new_user_2_email
      expect(page).to have_content 'Pending.'
    end
  end

  let(:emails) { %w(test1@test.com test2@test.com test3@test.com) }

  scenario 'Send invitations' do
    visit root_path

    fill_in 'Emails', with: emails.join(',')

    expect_any_instance_of(User).to receive(:invite_all).with(emails)
    click_button 'Send invitations'
  end
end
