class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    %i(accept_invitation sign_up account_update).each do |symbol|
      devise_parameter_sanitizer.for(symbol).concat User.new_allowed_attributes
    end
  end
end
