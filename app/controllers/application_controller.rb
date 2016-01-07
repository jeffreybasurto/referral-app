class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_agent!
  before_filter :set_locale

  protected
  def default_url_options(options = {})
    url_options = { locale: I18n.locale }.merge options

    if agent_signed_in? && current_agent.locale != url_options[:locale].to_s && I18n.available_locales.map(&:to_s).include?(url_options[:locale].to_s)
      current_agent.update_attribute(:locale, url_options[:locale])
    end

    url_options
  end

  def devise_parameter_sanitizer
    if resource_class == Agent
      Agent::ParameterSanitizer.new(Agent, :agent, params)
    else
      super
    end
  end

  private
  def set_locale
    I18n.locale = if params[:locale]
      params[:locale]
    elsif agent_signed_in?
      current_agent.locale
    else
      I18n.default_locale
    end
  end

  def set_admin_locale
    I18n.locale = :en
  end
end