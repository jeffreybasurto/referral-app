class Agent::ParameterSanitizer < Devise::ParameterSanitizer
  def accept_invitation
    default_params.permit(:invitation_token, :bank_name, :insurance_company_name, :first_name, :last_name,
                          :phone, :dob, :account_name, :account_number, :branch_name, :branch_address)
  end
end
