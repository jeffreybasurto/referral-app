class Organisation < ActiveRecord::Base
  default_scope { order('id ASC') }

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  has_many :agents, dependent: :destroy, inverse_of: :organisation

  scope :non_test, -> { where.not(test: true) }

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
    self.agents.where(invitation_sent_at: nil, invitation_token: nil).where.not(invited_by_id: nil).count
  end

  def agents_excluding(agent)
    unless agent.is_a? Agent
      raise ArgumentError.new('Wrong argument type')
    end

    self.agents.where.not(id: [agent.id] + agent.get_all_children.map(&:id))
  end
end
