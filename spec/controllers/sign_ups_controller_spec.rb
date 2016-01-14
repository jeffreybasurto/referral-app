require 'rails_helper'

RSpec.describe SignUpsController, type: :controller do
  describe 'GET new' do
    it 'assigns new organisation' do
      get :new
      expect(assigns(:agent)).not_to be_persisted
    end
  end

  describe 'POST create' do
    let!(:org) { create(:organisation) }
    let(:params) {
      attrs = build(:agent, organisation: org).attributes
      attrs['password'] = 'password'
      attrs['password_confirmation'] = 'password'
      attrs
    }

    context 'existing organisation chosen' do
      it 'should assign agent to existing organisation' do
        expect {
          post :create, agent: params.merge(organisation_name: org.name)
        }.to change { org.agents.count }.by 1
        expect(Organisation.count).to eq 1
      end
    end

    context 'new organisation' do
      let(:new_org_name) { 'New name' }

      it 'should assign agent to existing organisation' do
        expect {
          post :create, agent: params.merge(organisation_name: new_org_name)
        }.to change { Organisation.count }.by 1
        expect(Organisation.last.name).to eq new_org_name
        expect(Organisation.last.agents.count).to eq 1
        expect(org.agents.count).to eq 0
      end
    end
  end
end
