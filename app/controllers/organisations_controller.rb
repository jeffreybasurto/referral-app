class OrganisationsController < ApplicationController
  skip_before_filter :authenticate_agent!
  autocomplete :organisation, :name, full: true, scopes: [:non_test]

  def new
    @organisation = Organisation.new
    @organisation.agents.build
  end

  def create
    @organisation = Organisation.where(name: org_params[:name]).take

    if @organisation
      @organisation.attributes = org_params
    else
      @organisation = Organisation.new org_params
    end

    if @organisation.save
      sign_in(@organisation.agents.find_by_email(org_params[:agents_attributes]['0'][:email]))
      redirect_to root_path, notice: I18n.t('devise.registrations.signed_up')
    else
      render 'new'
    end
  end

  private
  def org_params
    params.require(:organisation).permit(:name, agents_attributes: (Agent::PERMITTED_ATTRIBUTES - [:organisation_id]))
  end
end
