class Organisation::ParameterSanitizer < Devise::ParameterSanitizer
  def sign_up
    default_params.permit(:email, :name, :password, :password_confirmation)
  end
end
