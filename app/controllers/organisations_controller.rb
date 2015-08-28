class OrganisationsController < ApplicationController
  def index
    @agents = current_organisation.agents
  end

  def reveal_referral_link
    @referral_token = current_organisation.referral_token

    render 'reveal'
  end
end
