require 'rails_helper'

migration_file_name = Dir[Rails.root.join('db/migrate/*_remove_devise_from_organisations.rb')].first
require migration_file_name

class Organisation
  include DeviseInvitable::Inviter
end

describe RemoveDeviseFromOrganisations, migration: true do
  subject { RemoveDeviseFromOrganisations.new }

  describe '#up' do
    before do
      ActiveRecord::Migrator.down('db/migrate', 20151008041224) if ActiveRecord::Migrator.current_version > 20151008041224
      subject.down if ActiveRecord::Migrator.current_version == 20151008041224
    end

    after do
      ActiveRecord::Migrator.migrate 'db/migrate'
    end

    context 'errors' do
      it 'checks if agent already exists for the organisation' do
        org = create(:organisation)
        expect { subject.up }.to raise_error(Exception, "Missing agents with emails #{[org.email]}")
      end

      it 'checks if agent is in wrong organisation' do
        org_1 = Organisation.create(email: 'test@test.com', name: 'Test')
        org_2 = Organisation.create(email: 'test_1@test.com', name: 'Test 2')
        build(:agent, email: org_1.email, organisation: org_2).save(validate: false)
        build(:agent, email: org_2.email, organisation: org_2).save(validate: false)

        expect { subject.up }.to raise_error(Exception, "Agent with email #{org_1.email} might be in wrong Organisation. Please check.")
      end
    end

    it 'transfer invites from organisation to agent' do
      org   = Organisation.create(email: 'test@test.com', name: 'Test')
      agent = build(:agent, organisation: org, email: org.email)
      agent.save(validate: false)
      invite = Agent.invite!({ email: 'test1@example.com', skip_invitation: true }, agent)
      Agent.accept_invitation!(invitation_token: invite.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch', organisation: org)

      expect {
        invite = Agent.invite!({ email: 'test2@example.com', skip_invitation: true }, org)
        Agent.accept_invitation!(invitation_token: invite.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch', organisation: org)
        invite = Agent.invite!({ email: 'test3@example.com', skip_invitation: true }, org)
        Agent.accept_invitation!(invitation_token: invite.raw_invitation_token, bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'First', last_name: 'Last', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch', organisation: org)

        subject.up
        agent.reload
      }.to change(agent.invitations, :count).from(1).to(3)
    end
  end
end