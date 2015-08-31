class LocalesController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  skip_before_filter :authenticate_organisation!
  skip_before_filter :set_locale

  def update
    locale = locale_params

    if locale.present?
      url_hash = Rails.application.routes.recognize_path URI(request.referer).path

      if organisation_signed_in?
        current_organisation.locale = locale
        current_organisation.save
      end

      url_hash[:locale] = locale
      redirect_to url_hash
    else
      redirect_to :back
    end
  end

  private
  def locale_params
    locale = params[:new_locale]
    locale = locale.to_sym if locale.present?
    locale
  end
end