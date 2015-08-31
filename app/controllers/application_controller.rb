class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_organisation!
  before_filter :set_locale

  def after_sign_in_path_for(resource_or_scope)
    if resource_or_scope.is_a?(Organisation) && resource_or_scope.locale !=  I18n.locale
      I18n.locale = resource_or_scope.locale
      organisations_path
    else
      super
    end
  end

  protected
  def default_url_options(options = {})
    { locale: I18n.locale }.merge options
  end

  def devise_parameter_sanitizer
    if resource_class == Agent
      Agent::ParameterSanitizer.new(Agent, :agent, params)
    elsif resource_class == Organisation
      Organisation::ParameterSanitizer.new(Organisation, :organisation, params)
    else
      super
    end
  end

  private
  def set_locale
    I18n.locale = if params[:locale]
      params[:locale]
    elsif organisation_signed_in?
      current_organisation.locale
    else
      I18n.default_locale
    end
  end
end