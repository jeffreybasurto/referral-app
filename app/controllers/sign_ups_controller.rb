class SignUpsController < ApplicationController
  skip_before_filter :authenticate_agent!
  autocomplete :organisation, :name, full: true, scopes: [:non_test]
  before_action :build_agent

  def new
  end

  def create
    org_name = sign_up_params[:organisation_name]
    organisation = Organisation.where(name: org_name).take

    unless organisation
      organisation = Organisation.new(name: org_name)
    end

    @agent.attributes = sign_up_params.except(:organisation_name)
    @agent.organisation = organisation

    if @agent.save
      sign_in(@agent)
      redirect_to root_path, notice: I18n.t('devise.registrations.signed_up')
    else
      render 'new'
    end
  end

  private
  def sign_up_params
    params.require(:agent).permit(Agent::PERMITTED_ATTRIBUTES - [:organisation_id] + [:organisation_name])
  end

  def build_agent
    @agent ||= Agent.new
    @agent.organisation = Organisation.new unless @agent.organisation.present?
  end
end
