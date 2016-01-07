require 'rails_helper'

RSpec.describe OrganisationsController, type: :controller do
  describe 'GET new' do
    it 'assigns new organisation' do
      get :new
      expect(assigns(:organisation)).not_to be_persisted
    end
  end

  describe 'POST create' do
    let!(:org) { create(:organisation) }
    let(:agent_attributes) {
      attrs = build(:agent, organisation: org).attributes
      attrs['password'] = 'password'
      attrs['password_confirmation'] = 'password'
      attrs
    }

    context 'existing organisation chosen' do
      it 'should assign agent to existing organisation' do
        expect {
          post :create, organisation: { name: org.name, agents_attributes: { '0' => agent_attributes } }
        }.to change { org.agents.count }.by 1
        expect(Organisation.count).to eq 1
      end
    end

    context 'new organisation' do
      let(:new_org_name) { 'New name' }

      it 'should assign agent to existing organisation' do
        expect {
          post :create, organisation: { name: new_org_name, agents_attributes: { '0' => agent_attributes } }
        }.to change { Organisation.count }.by 1
        expect(Organisation.last.name).to eq new_org_name
        expect(Organisation.last.agents.count).to eq 1
        expect(org.agents.count).to eq 0
      end
    end
  end
end
