class InvitationsController < ApplicationController
  def create
    emails = invitation_params[:emails].split(',')

    current_organisation.invite_all(emails)
    redirect_to organisations_path
  end

  private
  def invitation_params
    params.require(:invitations).permit(:emails)
  end
end
