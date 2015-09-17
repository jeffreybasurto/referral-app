require 'rails_helper'
include ActiveJob::TestHelper

RSpec.feature 'Change locale', type: :feature do
  pending 'TODO' do
    let(:locale) { :en }
    let(:new_locale) { :id }
    subject { create(:organisation, locale: locale) }
    let(:agent_params) { build(:agent) }
    let!(:agent) { Agent.invite!({ email: agent_params.email, skip_invitation: true }, subject) }

    before do
      I18n.locale = locale
    end

    scenario 'Change locale after login' do
      login_as(subject, :scope => :organisation)
      visit root_path

      expect(page.find('.dropdown-toggle').text).to eq ApplicationHelper::LOCALES[locale]
      expect {
        click_link ApplicationHelper::LOCALES[new_locale]
        expect(page.find('.dropdown-toggle').text).to eq ApplicationHelper::LOCALES[new_locale]
        subject.reload
      }.to change(subject, :locale).from(locale.to_s).to(new_locale.to_s)
    end

    scenario 'Change locale while signing up (Organisation)' do
      #TODO fix this spec
      visit new_organisation_registration_path

      fill_in 'organisation[email]', with: 'email'
      click_button I18n.t('helpers.submit.organisation.create')

      expect(page).to have_content 'is invalid'
      expect(page.find('.dropdown-toggle').text).to eq ApplicationHelper::LOCALES[locale]

      expect {
        click_link ApplicationHelper::LOCALES[new_locale]
        expect(page.find('.dropdown-toggle').text).to eq ApplicationHelper::LOCALES[new_locale]
        subject.reload
      }.to change(subject, :locale).from(locale.to_s).to(new_locale.to_s)

      expect(page).to have_content 'is invalid'
    end

    scenario 'Change locale while signing up via email' do
      visit accept_agent_invitation_path(invitation_token: agent.raw_invitation_token)

      fill_in 'agent[first_name]', with: 'Test'
      click_button I18n.t('helpers.submit.agent.update')

      expect(page).to have_content "can't be blank"
      expect(page.find('.dropdown-toggle').text).to eq ApplicationHelper::LOCALES[locale]

      expect {
        click_link ApplicationHelper::LOCALES[new_locale]
        expect(page.find('.dropdown-toggle').text).to eq ApplicationHelper::LOCALES[new_locale]
        subject.reload
      }.to change(subject, :locale).from(locale.to_s).to(new_locale.to_s)

      expect(page).to have_content 'tidak bisa kosong'
    end
  end
end