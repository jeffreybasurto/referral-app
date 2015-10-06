class Agent::ParameterSanitizer < Devise::ParameterSanitizer
  def accept_invitation
    default_params.permit(Agent::PERMITTED_ATTRIBUTES)
  end

  def sign_up
    default_params.permit(Agent::PERMITTED_ATTRIBUTES)
  end
end
