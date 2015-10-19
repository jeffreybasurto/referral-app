class AgentMailerPreview < ActionMailer::Preview
  def invitation_instructions(inviter = nil)
    token = Devise.friendly_token 20
    if inviter
      AgentMailer.invitation_instructions mock_agent(inviter), token
    else
      AgentMailer.invitation_instructions mock_agent, token
    end
  end

  def password_reset
    password = Devise.friendly_token 8
    AgentMailer.password_reset mock_agent, password
  end

  private
  def mock_agent(inviter = Agent.new(invite_email_body: 'testing email body', invite_email_subject: 'custom subject line'))
    Agent.new(email: 'sample@example.com',bank_name: 'Mandiri', insurance_company_name: 'AIA FINANCIAL', first_name: 'Bill', last_name: 'Gates', phone: '+62 21 6539-0605', dob: '27/08/1985', account_name: 'tester account', account_number: '123123123123123', branch_name: 'random bank branch', invited_by: inviter)
  end
end
