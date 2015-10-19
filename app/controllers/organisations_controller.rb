class OrganisationsController < ApplicationController
  skip_before_filter :authenticate_agent!, only: [:new, :create]

  def new
    @organisation = Organisation.new
    @organisation.agents.build
  end

  def create
    @organisation = Organisation.new org_params

    if @organisation.save
      sign_in(@organisation.agents.first)
      redirect_to root_path, notice: I18n.t('devise.registrations.signed_up')
    else
      render 'new'
    end
  end

  private
  def org_params
    params.require(:organisation).permit(:name, agents_attributes: Agent::PERMITTED_ATTRIBUTES)
  end
end
