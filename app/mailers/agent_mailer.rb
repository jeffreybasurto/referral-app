class AgentMailer < Devise::Mailer
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  default template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def invitation_instructions(record, token, opts={})
    @token = token
    opts[:subject] = record.invited_by.invite_email_subject if record.invited_by.invite_email_subject.present?
    opts[:reply_to] = record.invited_by.email
    opts[:content_type] = 'text/html'
    devise_mail(record, :invitation_instructions, opts)
  end

  def password_reset(record, password)
    @name     = record.name
    @password = password
    mail(to: record.email, subject: 'Password reset notice.', template_path: 'agents/mailer')
  end
end