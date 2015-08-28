class Agent < ActiveRecord::Base
  BANK_NAMES          = %w(BCA Mandiri)
  INSURANCE_COMPANIES = %w(ACE\ LIFE\ ASSURANCE ADISARANA\ WANAARTHA AIA\ FINANCIAL ALLIANZ\ LIFE\ INDONESIA AVIVA\ INDONESIA AVRIST\ ASSURANCE AXA\ FINANCIAL\ INDONESIA AXA\ LIFE\ INDONESIA AXA\ MANDIRI\ FINANCIALSERVICES BAKRIE\ LIFE BNI\ LIFE\ INSURANCE BRINGIN\ JIWA\ SEJAHTERA BUMIPUTERA\ 1912 CENTRAL\ ASIA\ FINANCIAL CENTRAL\ ASIA\ RAYA CIGNA CIMB\ SUN\ LIFE COMMONWEALTH\ LIFE EQUITY\ LIFE\ INDONESIA FINANCIAL\ WIRAMITRA\ DANADYAKSA GENERALI\ INDONESIA GREAT\ EASTERN\ LIFE\ INDONESIA HANWHA\ LIFE\ INSURANCE\ INDONESIA HEKSA\ EKA\ LIFE\ INSURANCE INDOLIFE\ PENSIONTAMA INDOSURYA\ SUKSES INHEALTH\ INDONESIA JIWASRAYA KRESNA\ LIFE MANULIFE\ INDONESIA MASKAPAI\ REASURANSI\ INDONESIA MEGA\ INDONESIA MNC\ LIFE\ ASSURANCE PANIN\ DAI-ICHI\ LIFE PASARAYA\ LIFE PRUDENTIAL\ LIFE\ ASSURANCE REASURANSI\ INTERNATIONAL\ INDONESIA REASURANSI\ NASIONAL\ INDONESIA RECAPITAL RELIANCE\ INDONESIA SEQUIS\ FINANCIAL SEQUIS\ LIFE SINARMAS\ MSIG SUN\ LIFE\ FINANCIAL\ INDONESIA SYARIAH\ ALAMIN SYARIAH\ AMANAHJIWA\ GIRI\ ARTHA TAKAFUL\ KELUARGA TOKIO\ MARINE\ LIFE\ INSURANCE\ INDONESIA TUGU\ MANDIRI TUGU\ REASURANSI\ INDONESIA ZURICH\ TOPAS\ LIFE)

  default_scope { order('id ASC') }
  belongs_to :organisation
  devise :invitable

  validates :email, presence: true, uniqueness: true
  validates :bank_name, presence: true, inclusion: BANK_NAMES
  validates :insurance_company_name, presence: true, inclusion: INSURANCE_COMPANIES
  validates_presence_of :first_name, :phone, :dob, :organisation, :account_name, :account_number, :branch_name
  validates_plausible_phone :phone, presence: true, default_country_code: 'ID'
  validate :dob_valid?

  attr_accessor :password #to make devise_invitable happy

  def name
    last_name.present? ? "#{first_name} #{last_name}" : first_name
  end

  def docdoc_agent_id
    self.id.to_s(36)
  end

  def send_intro_email
    #TODO
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

  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
