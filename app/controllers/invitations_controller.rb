class InvitationsController < ApplicationController
  def create
    emails = invitation_params[:emails].split(',')

    current_agent.invite_all(emails)
    redirect_to agents_path
  end

  private
  def invitation_params
    params.require(:invitations).permit(:emails)
  end
end
