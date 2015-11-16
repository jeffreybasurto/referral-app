require 'rails_helper'

RSpec.describe InvitationsController, type: :controller do
  subject { create(:agent) }

  before { sign_in subject }

  describe 'POST create' do
    let(:emails) { (1..5).map { |i| "email#{i}@test.com" } }
    context 'comma separated values' do
      it 'send invites' do
        expect_any_instance_of(Agent).to receive(:invite_all).with emails
        post :create, invitations: { emails: emails.join(',') }
      end
    end

    context 'multiline values with \n' do
      it 'send invites' do
        expect_any_instance_of(Agent).to receive(:invite_all).with emails
        post :create, invitations: { emails: emails.join("\n") }
      end
    end

    context 'multiline values with \r\n' do
      it 'send invites' do
        expect_any_instance_of(Agent).to receive(:invite_all).with emails
        post :create, invitations: { emails: emails.join("\r\n") }
      end
    end

    context 'multiline values with comma at the end' do
      it 'send invites' do
        emails_2 = (1..5).map { |i| "email#{2*i}@test.com" }
        expect_any_instance_of(Agent).to receive(:invite_all).with emails + emails_2
        post :create, invitations: { emails: emails.join("\r\n") + "\r\n" + emails_2.join(",\r\n") }
      end
    end
  end
end
