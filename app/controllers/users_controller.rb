class UsersController < ApplicationController
  def index
    @referrals = current_user.referrals
  end
end
