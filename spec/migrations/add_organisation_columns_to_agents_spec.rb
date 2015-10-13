require 'rails_helper'

migration_file_name = Dir[Rails.root.join('db/migrate/*_add_organisation_columns_to_agents.rb')].first
require migration_file_name

describe AddOrganisationColumnsToAgents, migration: true do
  subject { AddOrganisationColumnsToAgents.new }

  describe '#up' do
    before do
      ActiveRecord::Migrator.down('db/migrate', 20151006054859) if ActiveRecord::Migrator.current_version > 20151006054859
      subject.down if ActiveRecord::Migrator.current_version == 20151006054859
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
        org_1 = Organisation.create(email: 'test1@test.com', name: 'Test')
        org_2 = Organisation.create(email: 'test2@test.com', name: 'Test 2')
        org_3 = Organisation.create(email: 'test3@test.com', name: 'Test 3')
        build(:agent, email: org_1.email, organisation: org_3).save(validate: false)
        build(:agent, email: org_2.email, organisation: org_1).save(validate: false)
        build(:agent, email: org_3.email, organisation: org_2).save(validate: false)

        expect { subject.up }.to raise_error(Exception, "Agents with email #{[org_1.email, org_2.email, org_3.email].join(', ')} might be in wrong Organisation. Please check.")
      end

      it "doesn't modify existing data" do
        org_1 = Organisation.create(email: 'test1@test.com', name: 'Test')
        org_2 = Organisation.create(email: 'test2@test.com', name: 'Test 2')
        org_3 = Organisation.create(email: 'test3@test.com', name: 'Test 3')
        org_4 = Organisation.create(email: 'test4@test.com', name: 'Test 4', encrypted_password: 'test')
        build(:agent, email: org_1.email, organisation: org_3).save(validate: false)
        build(:agent, email: org_2.email, organisation: org_1).save(validate: false)
        build(:agent, email: org_3.email, organisation: org_2).save(validate: false)
        agent = build(:agent, email: org_4.email, organisation: org_4, encrypted_password: 'agent_test')
        agent.save(validate: false)

        expect { subject.up }.to raise_error(Exception, "Agents with email #{[org_1.email, org_2.email, org_3.email].join(', ')} might be in wrong Organisation. Please check.")
        expect(agent.reload.encrypted_password).to eq 'agent_test'
      end
    end

    it 'adds columns to agents table' do
      expect(Agent.columns.map(&:name)).to_not include %w(locale referral_token ref_link_generated_count mails_sent)
      expect {
        subject.up
        Agent.reset_column_information
      }.to change { Agent.columns }
      expect(Agent.columns.map(&:name)).to include *%w(locale referral_token ref_link_generated_count mails_sent)
    end

    it 'transfer stats from organisation to agent' do
      org   = Organisation.create(email: 'test@test.com', name: 'Test', locale: :en, encrypted_password: 'abcdef', referral_token: 'abc', ref_link_generated_count: 3, mails_sent: 5)
      agent = build(:agent, organisation: org, email: org.email)
      agent.save(validate: false)
      subject.up
      agent.reload

      expect(agent.attributes.slice(*%w(encrypted_password locale referral_token ref_link_generated_count mails_sent))).to match_array org.attributes.slice(*%w(encrypted_password locale referral_token ref_link_generated_count mails_sent))
    end
  end
end