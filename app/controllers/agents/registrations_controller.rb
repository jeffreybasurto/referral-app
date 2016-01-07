class Agents::RegistrationsController < Devise::RegistrationsController
  before_filter :fetch_inviter, only: [:new, :create]

  def new
    @token = params['invitation_token']
    build_resource(organisation: @inviter.organisation, insurance_company_name: @inviter.insurance_company_name)
    set_minimum_password_length
    yield resource if block_given?
    respond_with self.resource
  end

  def create
    params['agent']['invited_by_id'] = @inviter.id
    params['agent']['invited_by_type'] = @inviter.class.name
    super
  end

  private
  def fetch_inviter
    @inviter = Agent.where(referral_token: params['invitation_token']).first
    raise ActiveRecord::RecordNotFound.new(I18n.t('errors.messages.page_not_found')) unless @inviter.present?
  end
end