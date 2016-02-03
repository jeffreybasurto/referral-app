class Agent < ActiveRecord::Base
  default_scope { order('id ASC') }

  BANK_NAMES           = %w(BCA Mandiri).freeze
  INSURANCE_COMPANIES  = %w(OTHERS\ NOT\ LISTED ACE\ LIFE\ ASSURANCE ADISARANA\ WANAARTHA AIA\ FINANCIAL ALLIANZ\ LIFE\ INDONESIA AVIVA\ INDONESIA AVRIST\ ASSURANCE AXA\ FINANCIAL\ INDONESIA AXA\ LIFE\ INDONESIA AXA\ MANDIRI\ FINANCIALSERVICES BAKRIE\ LIFE BNI\ LIFE\ INSURANCE BRINGIN\ JIWA\ SEJAHTERA BUMIPUTERA\ 1912 CENTRAL\ ASIA\ FINANCIAL CENTRAL\ ASIA\ RAYA CIGNA CIMB\ SUN\ LIFE COMMONWEALTH\ LIFE EQUITY\ LIFE\ INDONESIA FINANCIAL\ WIRAMITRA\ DANADYAKSA GENERALI\ INDONESIA GREAT\ EASTERN\ LIFE\ INDONESIA HANWHA\ LIFE\ INSURANCE\ INDONESIA HEKSA\ EKA\ LIFE\ INSURANCE INDOLIFE\ PENSIONTAMA INDOSURYA\ SUKSES INHEALTH\ INDONESIA JIWASRAYA KRESNA\ LIFE MANULIFE\ INDONESIA MASKAPAI\ REASURANSI\ INDONESIA MEGA\ INDONESIA MNC\ LIFE\ ASSURANCE PANIN\ DAI-ICHI\ LIFE PASARAYA\ LIFE PRUDENTIAL\ LIFE\ ASSURANCE REASURANSI\ INTERNATIONAL\ INDONESIA REASURANSI\ NASIONAL\ INDONESIA RECAPITAL RELIANCE\ INDONESIA SEQUIS\ FINANCIAL SEQUIS\ LIFE SINARMAS\ MSIG SUN\ LIFE\ FINANCIAL\ INDONESIA SYARIAH\ ALAMIN SYARIAH\ AMANAHJIWA\ GIRI\ ARTHA TAKAFUL\ KELUARGA TOKIO\ MARINE\ LIFE\ INSURANCE\ INDONESIA TUGU\ MANDIRI TUGU\ REASURANSI\ INDONESIA ZURICH\ TOPAS\ LIFE).freeze
  PERMITTED_ATTRIBUTES = %i(email invitation_token bank_name insurance_company_name first_name last_name phone dob account_name account_number branch_name branch_address password password_confirmation organisation_id invited_by_id invited_by_type).freeze
  CSV_HEADERS          = %w(email first_name last_name phone dob insurance_company_name bank_name account_name branch_name branch_address account_number inviter_email).freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  belongs_to :organisation
  has_many :invitations, class_name: self.to_s, as: :invited_by

  before_validation :generate_agent_id, :generate_referral_token

  validates :email, presence: true, uniqueness: true
  validates :referral_token, presence: true, uniqueness: true
  validates :locale, inclusion: I18n.available_locales.map(&:to_s), allow_blank: true, allow_nil: true
  validates :bank_name, inclusion: BANK_NAMES, allow_blank: true
  validates :insurance_company_name, presence: true, inclusion: INSURANCE_COMPANIES
  validates_presence_of :first_name, :phone, :dob, :organisation
  validates_plausible_phone :phone, presence: true, default_country_code: 'ID'
  validate :dob_valid?
  validates :invited_by_id, numericality: { greater_than: 0, allow_blank: true, message: 'email is not valid' }

  delegate :name, to: :organisation, prefix: true
  delegate :email, to: :invited_by, prefix: true, allow_nil: true

  def invite_all(emails = [])
    emails.each do |email|
      self.class.invite!({ email: email, organisation: organisation, insurance_company_name: insurance_company_name }, self)
      self.increment!(:mails_sent)
    end
  end

  def gen_ref_token_for_link
    self.increment!(:ref_link_generated_count)
    self.referral_token
  end

  def unique_mails_sent
    self.invitations.created_by_invite.count
  end

  def invitations_accepted
    self.invitations.invitation_accepted.count
  end

  def agents_via_ref_link
    self.invitations.where(invitation_sent_at: nil, invitation_token: nil).count
  end

  def name
    last_name.present? ? "#{first_name} #{last_name}" : first_name
  end

  def get_all_children
    if self.invitations.empty?
      []
    else
      sql = <<-EOF
      WITH RECURSIVE children (id, invited_by_id) AS (
        SELECT * FROM agents WHERE invited_by_id = #{self.id}
        UNION ALL
        SELECT ag.*
        FROM agents ag
        JOIN children ch ON ag.invited_by_id = ch.id
      )
      SELECT * from children;
      EOF

      Agent.find_by_sql(sql)
    end
  end

  def self.import_csv(file_name)
    require 'smarter_csv'

    key_mappings = {
      email_address:       :email,
      given_name:          :first_name,
      family_name:         :last_name,
      phone_number:        :phone,
      date_of_birth:       :dob,
      bank_branch_address: :branch_address,
      bank_branch:         :branch_name
    }

    invalid_rows = []
    new_agent_ids = []
    Agent.transaction do
      SmarterCSV.process(file_name, key_mapping: key_mappings) do |row|
        row     = row.first
        inviter = Agent.where(email: row.delete(:inviter_email)).take

        if inviter
          agent                 = Agent.new(row.slice(*CSV_HEADERS.map(&:to_sym)))
          agent.password        = agent.email
          agent.invited_by_id   = inviter.id
          agent.invited_by_type = Agent
          agent.locale          = inviter.locale
          agent.organisation_id = inviter.organisation_id

          if agent.valid?
            agent.save
            new_agent_ids << agent.id
          else
            row[:errors] = agent.errors.full_messages.join('. ')
            invalid_rows << row
          end
        else
          row[:errors] = "Can't find inviter with email: '#{row[:inviter_email]}'"
          invalid_rows << row
        end

      end

      unless invalid_rows.empty?
        raise ActiveRecord::Rollback, 'Invalid records found in the CSV.'
      end
    end

    if invalid_rows.empty?
      new_agent_ids.each { |id| AgentImportInviteMailer.import_invite(id).deliver_later }
      { success: true }
    else
      { success: false, invalid_rows: invalid_rows }
    end
  end

  private
  def dob_valid?
    begin
      Time.parse(self.dob.to_s)
    rescue ArgumentError
      self.errors.add(:dob, 'is not in an acceptable format')
      return false
    end
  end

  def generate_agent_id
    return if self.agent_id.present?
    length = 6

    loop do
      self.agent_id = Devise.friendly_token(length)
      if Agent.where(agent_id: self.agent_id).count.zero?
        break
      else
        length += 1
      end
    end
  end

  def generate_referral_token
    return if self.referral_token.present?
    length = 20

    loop do
      self.referral_token = Devise.friendly_token(length)
      if Agent.where(referral_token: self.referral_token).count.zero?
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
