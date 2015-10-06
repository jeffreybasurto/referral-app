class Agents::RegistrationsController < Devise::RegistrationsController
  before_filter :fetch_organisation, only: [:new]

  def new
    build_resource(organisation: @organisation)
    set_minimum_password_length
    yield resource if block_given?
    respond_with self.resource
  end

  private
  def fetch_organisation
    @organisation = Organisation.where(referral_token: params['invitation_token']).first
    raise ActiveRecord::RecordNotFound.new(I18n.t('errors.messages.page_not_found')) unless @organisation.present?
  end
end