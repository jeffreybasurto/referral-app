class MailTemplatesController < ApplicationController
  before_action :fetch_preview

  def show
    @agent = current_agent
  end

  def update
    @agent = current_agent

    if @agent.update_attributes(template_params)
      render 'show', notice: I18n.t('update_success')
    else
      render 'show'
    end
  end

  def preview_body
    part                  = AgentMailerPreview.new.invitation_instructions(current_agent)
    response.content_type = Mime::TEXT
    render text: part.respond_to?(:decoded) ? part.decoded : part
  end

  private
  def fetch_preview
    @preview ||= AgentMailerPreview
    @email   ||= @preview.new.invitation_instructions(current_agent)
    @part    ||= @email
  end

  def template_params
    params.require(:agent).permit(:invite_email_subject, :invite_email_body)
  end
end