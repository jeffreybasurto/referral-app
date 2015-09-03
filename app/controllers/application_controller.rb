class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_organisation!
  before_filter :set_locale

  def after_accept_path_for(resource)
    finished_agents_path(agent_id: resource.agent_id)
  end

  protected
  def default_url_options(options = {})
    url_options = { locale: I18n.locale }.merge options

    if organisation_signed_in? && current_organisation.locale != url_options[:locale].to_s && I18n.available_locales.map(&:to_s).include?(url_options[:locale].to_s)
      current_organisation.update_attribute(:locale, url_options[:locale])
    end

    url_options
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