class Organisation < ActiveRecord::Base
  default_scope { order('id ASC') }

  validates :name, presence: true, uniqueness: true

  has_many :agents, dependent: :destroy, inverse_of: :organisation
  accepts_nested_attributes_for :agents

  def total_ref_link_generated_count
    self.agents.sum(:ref_link_generated_count)
  end

  def total_mails_sent
    self.agents.sum(:mails_sent)
  end

  def unique_mails_sent
    self.agents.created_by_invite.count
  end

  def invitations_accepted
    self.agents.invitation_accepted.count
  end

  def invitations_pending
    self.agents.invitation_not_accepted.count
  end

  def agents_via_ref_link
    self.agents.where(invitation_sent_at: nil, invitation_token: nil).count
  end
end
