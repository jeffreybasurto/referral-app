require 'rails_helper'

RSpec.describe 'User Dashboard', type: :request do
  let(:password) { 'abcdef1213' }
  subject { create(:user, password: password, password_confirmation: password) }
  let(:email) { subject.email }

  before { login(email, password) }

  describe 'GET users#index' do
    let(:new_user_1_email) { build(:user).email }
    let(:new_user_2_email) { build(:user).email }
    let!(:invited_user_1) { User.invite!({ email: new_user_1_email, skip_invitation: true }, subject) }
    let!(:invited_user_2) { User.invite!({ email: new_user_2_email, skip_invitation: true }, subject) }

    before do
      User.accept_invitation!(invitation_token: invited_user_1.raw_invitation_token, name: 'Tester', password: 'abcdef123', password_confirmation: 'abcdef123')
    end

    it 'displays invitation status' do
      get users_path

      expect(response.body).to include(new_user_1_email)
      expect(response.body).to include('Joined.')
      expect(response.body).to include(new_user_2_email)
      expect(response.body).to include('Pending.')
    end
  end
end

def login(email, password)
  post_via_redirect user_session_path, 'user[email]': email, 'user[password]': password
end