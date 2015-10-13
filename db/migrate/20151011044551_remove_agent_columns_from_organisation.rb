class RemoveAgentColumnsFromOrganisation < ActiveRecord::Migration
  def up
    change_table :organisations do |t|
      t.remove :locale
      t.remove :referral_token
      t.remove :ref_link_generated_count
      t.remove :mails_sent
    end
  end

  def down
    change_table :organisations do |t|
      t.string :locale
      t.string :referral_token
      t.integer :ref_link_generated_count, default: 0
      t.integer :mails_sent, default: 0
    end
  end
end
