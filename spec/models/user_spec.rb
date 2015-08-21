require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe User, type: :model do
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of :email }
  it { should validate_presence_of :name }
  it { should belong_to :referrer }
  it { should have_many :referrals }

  describe '#invite_all' do
    subject { create(:user) }

    it 'sends nothing' do
      assert_performed_jobs 0 do
        subject.invite_all([])
      end
    end

    context 'multiple emails' do
      let(:emails) { %w(test1@test.com test2@test.com test3@test.com) }

      it 'sends multiple invitation emails' do
        expect {
          assert_performed_jobs emails.count do
            subject.invite_all(emails)
          end
        }.to change(ActionMailer::Base.deliveries, :count).by(emails.count)
      end

      it 'creates multiple pending invitations' do
        expect {
          subject.invite_all(emails)
          subject.reload
        }.to change(subject.referrals, :count).by(emails.count)
        expect(subject.referrals.pluck(:email)).to match_array emails
      end
    end
  end
end
