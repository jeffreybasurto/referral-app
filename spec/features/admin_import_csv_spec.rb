require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'Admin import agent CSV', type: :feature do
  let(:password) { 'password' }
  let!(:admin_user) { create(:admin_user) }
  let!(:subject) { create(:agent, email: 'test@test.com') }

  before do
    clear_enqueued_jobs
    clear_performed_jobs

    visit new_admin_user_session_path
    fill_in 'admin_user[email]', with: admin_user.email
    fill_in 'admin_user[password]', with: password
    click_button 'Login'
    click_link 'Agents'
    click_link 'Import CSV'
  end

  scenario 'Imports valid CSV', :js do
    attach_file 'agent[csv]', Rails.root.join('spec', 'fixtures', 'agent_csvs', 'valid.csv')

    expect {
      perform_enqueued_jobs do
        expect {
          click_button 'Import CSV'
        }.to change(Agent, :count).by(13)
      end
    }.to change(ActionMailer::Base.deliveries, :count).by(13)
  end

  scenario 'Imports CSV with missing column', :js do
    attach_file 'agent[csv]', Rails.root.join('spec', 'fixtures', 'agent_csvs', 'missing_column.csv')
    expect(accept_alert).to eq 'Missing the following columns: Bank Branch Address'
    assert_enqueued_jobs 0 do
      expect {
        click_button 'Import CSV'
      }.to_not change(Agent, :count)
    end
  end

  scenario 'Imports CSV with missing parent in a row', :js do
    attach_file 'agent[csv]', Rails.root.join('spec', 'fixtures', 'agent_csvs', 'missing_parent.csv')
    assert_enqueued_jobs 0 do
      expect {
        click_button 'Import CSV'
      }.to_not change(Agent, :count)
    end
    expect(page).to have_content 'test4@test.com'
    expect(page).to have_content "Can't find inviter with email: ''"
  end
end
