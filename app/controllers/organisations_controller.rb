class OrganisationsController < ApplicationController
  def index
    @agents = current_organisation.agents.page(params[:page]).per(50)
  end

  def reveal_referral_link
    @referral_token = current_organisation.gen_ref_token_for_link

    render 'reveal'
  end
end
