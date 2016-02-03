class AgentImportInviteMailer < ApplicationMailer
  def import_invite(agent_id)
    @agent = Agent.find(agent_id)
    mail(to: @agent.email, subject: I18n.t('devise.mailer.invitation_instructions.subject'))
  end
end
