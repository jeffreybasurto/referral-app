require 'rails_helper'

RSpec.describe 'Organisation Dashboard', type: :request do
  let(:password) { 'abcdef1213' }
  subject { create(:organisation, password: password, password_confirmation: password) }
  let(:email) { subject.email }

  before { login(email, password) }

  describe 'GET organisations#index' do
    let(:agent_1_params) { build(:agent) }
    let(:agent_2_params) { build(:agent) }
    let!(:agent_1) { Agent.invite!({ email: agent_1_params.email, skip_invitation: true }, subject) }
    let!(:agent_2) { Agent.invite!({ email: agent_2_params.email, skip_invitation: true }, subject) }

    before do
      params = agent_1_params.attributes.symbolize_keys.slice(:bank_name, :insurance_company_name, :first_name, :last_name, :phone, :dob, :account_name, :account_number, :branch_name).merge(invitation_token: agent_1.raw_invitation_token)
      Agent.accept_invitation!(params)
    end

    it 'displays invitation status' do
      get organisations_path

      expect(response.body).to include(agent_1_params.email)
      expect(response.body).to include('Joined.')
      expect(response.body).to include(agent_2_params.email)
      expect(response.body).to include('Pending.')
    end
  end
end

def login(email, password)
  post_via_redirect organisation_session_path, 'organisation[email]': email, 'organisation[password]': password
end