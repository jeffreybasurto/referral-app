class AddReferralTokenToOrganisation < ActiveRecord::Migration
  def up
    add_column :organisations, :referral_token, :string
    Organisation.all.find_each do |org|
      org.referral_token = Devise.friendly_token(20)
      org.save!
    end
  end

  def down
    remove_column :organisations, :referral_token
  end
end
