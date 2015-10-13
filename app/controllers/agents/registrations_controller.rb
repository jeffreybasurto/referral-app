class Agents::RegistrationsController < Devise::RegistrationsController
  before_filter :fetch_inviter, only: [:new]

  def new
    build_resource(invited_by_id: @inviter.id, invited_by_type: @inviter.class.name, organisation: @inviter.organisation)
    set_minimum_password_length
    yield resource if block_given?
    respond_with self.resource
  end

  private
  def fetch_inviter
    @inviter = Agent.where(referral_token: params['invitation_token']).first
    raise ActiveRecord::RecordNotFound.new(I18n.t('errors.messages.page_not_found')) unless @inviter.present?
  end
end