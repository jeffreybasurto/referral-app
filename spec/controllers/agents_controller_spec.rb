require 'rails_helper'

RSpec.describe AgentsController, type: :controller do
  subject { create(:agent) }

  before { sign_in subject }

  describe 'GET index' do
    let(:agent_1_params) { build(:agent) }
    let(:agent_2_params) { build(:agent) }
    let!(:agent_1) { Agent.invite!({ email: agent_1_params.email, skip_invitation: true }, subject) }
    let!(:agent_2) { Agent.invite!({ email: agent_2_params.email, skip_invitation: true }, subject) }

    before do
      params = agent_1_params.attributes.symbolize_keys.slice(:bank_name, :insurance_company_name, :first_name, :last_name, :phone, :dob, :account_name, :account_number, :branch_name).merge(invitation_token: agent_1.raw_invitation_token)
      Agent.accept_invitation!(params)
    end

    it 'displays invitation status' do
      get :index
      expect(assigns(:agents)).to eq subject.invitations
    end
  end
end
