class AgentsController < ApplicationController
  skip_before_filter :authenticate_organisation!
  before_filter :fetch_organisation, only: [:new]

  def new
    @agent = Agent.new(organisation: @organisation)
  end

  def create
    @agent = Agent.new(agent_params.merge(invitation_sent_at: Time.current - 5.minutes, invitation_accepted_at: Time.current))
    #set invitation_sent_at will increment the created_by_invitation count, used for analytics
    #set invitation_accepted_at will increment the invitation_accepted count, used for analytics

    if @agent.save
      @agent.send_intro_email
      render text: 'Thank you for registering with us. An email has been sent with more information.'
    else
      render 'new'
    end
  end

  private
  def agent_params
    params.require(:agent).permit(:bank_name, :insurance_company_name, :first_name, :last_name,
                  :phone, :dob, :account_name, :account_number, :branch_name, :branch_address, :organisation_id, :email)
  end

  def fetch_organisation
    @organisation = Organisation.where(referral_token: params['invitation_token']).first
    raise ActionController::RoutingError.new('Page not found.') unless @organisation.present?
  end
end
