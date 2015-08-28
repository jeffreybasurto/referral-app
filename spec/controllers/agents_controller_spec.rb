require 'rails_helper'

RSpec.describe AgentsController, type: :controller do
  let(:org) { create(:organisation) }
  let(:referral_token) { org.referral_token }
  let(:params) do
    build(:agent).attributes.symbolize_keys.slice(:bank_name, :insurance_company_name, :first_name, :last_name, :phone, :dob, :account_name, :account_number, :branch_name).merge(invitation_token: referral_token)
  end

  describe 'GET new' do
    it 'assigns organisation to agent' do
      get :new, invitation_token: referral_token

      expect(assigns[:agent].organisation_id).to eq org.id
    end
  end
end
