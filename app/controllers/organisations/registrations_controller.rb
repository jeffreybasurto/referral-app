class Organisations::RegistrationsController < Devise::RegistrationsController
  def create
    if request.get?
      render 'new'
    else
      super
    end
  end
end