class InvitationsController < ApplicationController
  def create
    if invitation_params[:emails].lines.count > 1
      emails = invitation_params[:emails].gsub(',', '').split(/\r?\n/)
    else
      emails = invitation_params[:emails].split(',')
    end

    current_agent.invite_all(emails)
    redirect_to agents_path
  end

  private
  def invitation_params
    params.require(:invitations).permit(:emails)
  end
end
