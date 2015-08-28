class Agent::InvitationsController < Devise::InvitationsController
  def after_accept_path_for(resource)
    if resource_name == Agent
      resource.send_intro_email
      render text: I18n.t('devise.registrations.agent_success')
    end
  end
end
