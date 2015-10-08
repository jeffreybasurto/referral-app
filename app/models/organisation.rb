class Organisation < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  default_scope { order('id ASC') }
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseInvitable::Inviter

  validates :email, :name, presence: true, uniqueness: true

  has_many :agents, dependent: :destroy

  def invite_all(emails = [])
    emails.each do |email|
      Agent.invite!({ email: email }, self)
      self.increment!(:mails_sent)
    end
  end

  def gen_ref_token_for_link
    self.increment!(:ref_link_generated_count)
    self.referral_token
  end

  def unique_mails_sent
    self.agents.created_by_invite.count
  end

  def invitations_accepted
    self.agents.invitation_accepted.count
  end

  def agents_via_ref_link
    self.agents.where(invitation_sent_at: nil, invitation_token: nil).count
  end
end
