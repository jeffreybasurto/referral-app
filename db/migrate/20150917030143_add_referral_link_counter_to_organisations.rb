class AddReferralLinkCounterToOrganisations < ActiveRecord::Migration
  def change
    add_column :organisations, :ref_link_generated_count, :integer, default: 0
  end
end
