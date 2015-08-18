class UsersController < ApplicationController
  before_filter :authenticate_user!

  def index
    @referrals = current_user.referrals
  end
end
