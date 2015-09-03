class Agents::InvitationsController < Devise::InvitationsController
  def after_accept_path_for(resource)
    render text: I18n.t('devise.registrations.agent_success')
  end
end
