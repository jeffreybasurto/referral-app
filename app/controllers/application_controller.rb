class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_organisation!

  protected
  def devise_parameter_sanitizer
    if resource_class == Agent
      Agent::ParameterSanitizer.new(Agent, :agent, params)
    elsif resource_class == Organisation
      Organisation::ParameterSanitizer.new(Organisation, :organisation, params)
    else
      super
    end
  end
end