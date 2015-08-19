class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  default_scope { order('id ASC') }

  validates :email, presence: true, uniqueness: true
  belongs_to :referrer, class_name: 'User', foreign_key: 'invited_by_id'
  has_many :referrals, class_name: 'User', foreign_key: 'invited_by_id'

  def docdoc_agent_id
    self.id.to_s(36)
  end

  private

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
