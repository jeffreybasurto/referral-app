class AgentsController < ApplicationController
  skip_before_filter :authenticate_organisation!
  before_filter :fetch_organisation, only: [:new]

  def new
    @agent = Agent.new(organisation: @organisation)
  end

  def create
    @agent = Agent.new(agent_params.merge(invitation_sent_at: Time.current - 5.minutes, invitation_accepted_at: Time.current))

    if request.get? #should only happen if user change locale after submit
      render 'new'
    else
      #set invitation_sent_at will increment the created_by_invitation count, used for analytics
      #set invitation_accepted_at will increment the invitation_accepted count, used for analytics

      if @agent.save
        redirect_to finished_agents_path(agent_id: @agent.agent_id)
      else
        render 'new'
      end
    end
  end

  def finished
    @agent_id = params[:agent_id]
  end

  private
  def agent_params
    params.require(:agent).permit(:bank_name, :insurance_company_name, :first_name, :last_name,
                  :phone, :dob, :account_name, :account_number, :branch_name, :branch_address, :organisation_id, :email)
  end

  def fetch_organisation
    @organisation = Organisation.where(referral_token: params['invitation_token']).first
    raise ActiveRecord::RecordNotFound.new(I18n.t('errors.messages.page_not_found')) unless @organisation.present?
  end
end