class AgentsController < ApplicationController
  skip_before_filter :authenticate_agent!, only: [:new, :create]
  before_filter :get_agent, only: [:edit, :update]

  def index
    @agents = current_agent.invitations.page(params[:page]).per(50)
  end

  def reveal_referral_link
    @referral_token = current_agent.gen_ref_token_for_link

    render 'reveal'
  end
end
