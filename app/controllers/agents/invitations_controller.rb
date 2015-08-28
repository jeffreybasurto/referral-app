class Agent::InvitationsController < Devise::InvitationsController
  def after_accept_path_for(resource)
    if resource_name == Agent
      resource.send_intro_email
      render text: 'Thank you for registering with us. An email has been sent with more information.'
    end
  end
end
