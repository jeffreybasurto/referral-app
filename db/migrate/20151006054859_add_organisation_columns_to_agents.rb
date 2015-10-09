class AddOrganisationColumnsToAgents < ActiveRecord::Migration
  def up
    change_table :agents do |t|
      t.string :locale
      t.string :referral_token
      t.integer :ref_link_generated_count, default: 0
      t.integer :mails_sent, default: 0
    end

    org_emails = Organisation.pluck :email
    agent_emails = Agent.where(email: org_emails).pluck :email
    diff = org_emails - agent_emails

    if diff.empty?
      Organisation.find_each do |org|
        a = org.agents.find_by_email(org.email)
        if a.present?
          attrs = org.attributes.slice(*%w(encrypted_password locale referral_token ref_link_generated_count mails_sent))
          a.update_columns(attrs)
        else
          raise Exception, "Agent with email #{org.email} might be in wrong Organisation. Please check."
        end
      end
    else
      raise Exception, "Missing agents with emails #{diff}"
    end
  end

  def down
    Organisation.find_each do |org|
      a = Agent.find_by_email(org.email)
      if a.present?
        attrs = a.attributes.slice(*%w(encrypted_password locale referral_token ref_link_generated_count mails_sent))
        org.update_columns(attrs)
      else
        raise Exception
      end
    end

    change_table :agents do |t|
      t.remove :locale
      t.remove :referral_token
      t.remove :ref_link_generated_count
      t.remove :mails_sent
    end
  end
end
