class AddOrganisationColumnsToAgent < ActiveRecord::Migration
  def up
    add_column :agents, :locale, :string
    add_column :agents, :referral_token, :string
    add_column :agents, :ref_link_generated_count, :integer, default: 0
    add_column :agents, :mails_sent, :integer, default: 0

    org_emails = Organisation.pluck :email
    agent_emails = Agent.where(email: org_emails).pluck :email

    if org_emails == agent_emails
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
      raise Exception, "Missing agents with emails #{org_emails - agent_emails}"
    end
  end

  def down
    add_column :organisations, :locale, :string
    add_column :organisations, :referral_token, :string
    add_column :organisations, :ref_link_generated_count, :integer, default: 0
    add_column :organisations, :mails_sent, :integer, default: 0

    Organisation.find_each do |org|
      a = Agent.find_by_email(org.email)
      if a.present?
        attrs = a.attributes.slice(*%w(encrypted_password locale referral_token ref_link_generated_count mails_sent))
        org.update_columns(attrs)
      else
        raise Exception
      end
    end

    remove_column :agents, :locale
    remove_column :agents, :referral_token
    remove_column :agents, :ref_link_generated_count
    remove_column :agents, :mails_sent
  end
end
