require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  subject { create(:user) }

  before { sign_in subject }

  describe 'GET index' do
    let(:new_user_1_email) { build(:user).email }
    let(:new_user_2_email) { build(:user).email }
    let!(:invited_user_1) { User.invite!({ email: new_user_1_email, skip_invitation: true }, subject) }
    let!(:invited_user_2) { User.invite!({ email: new_user_2_email, skip_invitation: true }, subject) }

    before do
      User.accept_invitation!(invitation_token: invited_user_1.raw_invitation_token, password: 'abcdef', password_confirmation: 'abcdef')
    end

    it 'displays invitation status' do
      get :index
      expect(assigns(:referrals)).to eq subject.referrals
    end
  end
end
