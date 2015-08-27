class Organisation < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  include DeviseInvitable::Inviter

  default_scope { order('id ASC') }

  validates :email, presence: true, uniqueness: true
  validates_presence_of :name
  has_many :agents

  def invite_all(emails = [])
    emails.each do |email|
      Agent.invite!({ email: email }, self)
    end
  end

  private

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
