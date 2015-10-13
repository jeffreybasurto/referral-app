class OrganisationsController < ApplicationController
  skip_before_filter :authenticate_agent!, only: [:new, :create]

  def new
    @organisation = Organisation.new
  end

  def create
    @organisation = Organisation.new org_params

    if @organisation.save
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
