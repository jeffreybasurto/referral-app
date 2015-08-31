class Organisation < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseInvitable::Inviter

  default_scope { order('id ASC') }

  validates :email, presence: true, uniqueness: true
  validates :referral_token, presence: true, uniqueness: true
  validates :locale, inclusion: I18n.available_locales.map(&:to_s), allow_blank: true, allow_nil: true
  validates_presence_of :name

  before_validation :generate_referral_token
  has_many :agents, dependent: :destroy

  def invite_all(emails = [])
    emails.each do |email|
      Agent.invite!({ email: email }, self)
    end
  end

  def mails_sent
    self.agents.created_by_invite.count
  end

  def mails_accepted
    self.agents.invitation_accepted.count
  end

  private
  def generate_referral_token
    return if self.referral_token.present?
    length = 20

    loop do
      self.referral_token = Devise.friendly_token(length)
      if Organisation.where(referral_token: self.referral_token).count.zero?
        break
      else
        length += 1
      end
    end
  end

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
