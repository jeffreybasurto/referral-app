class RemoveDeviseFromOrganisations < ActiveRecord::Migration
  def up
    change_table :organisations do |t|
      test_orgs = ["jefry.yanto@docdoc.com", "charles.w.hewitt.ii@gmail.com", "emma@docdoc.com", "christian.dermawan@docdoc.com", "christoph.hannak@docdoc.com", "testerchris@test.tt", "cole.sirucek@docdoc.com", "test@example.com"]

      org_emails   = Organisation.pluck :email
      agent_emails = Agent.where(email: org_emails).pluck :email
      diff         = org_emails - agent_emails - test_orgs
      wrong_org    = []

      if diff.empty?
        Organisation.find_each do |org|
          next if test_orgs.include? org.email
          a = org.agents.find_by_email(org.email)
          unless a.present?
            wrong_org << org.email
          end
        end

        if wrong_org.present?
          raise Exception, "Agents with email #{wrong_org.join(', ')} might be in wrong Organisation. Please check."
        else
          Organisation.where.not(email: test_orgs).find_each do |org|
            a = org.agents.find_by_email(org.email)
            if a.present?
              org.agents.where.not(email: a.email).update_all(invited_by_id: a.id, invited_by_type: 'Agent')
            end
          end
        end
      else
        raise Exception, "Missing agents with emails #{diff}"
      end

      t.remove :email
      t.remove :encrypted_password
      t.remove :reset_password_token
      t.remove :reset_password_sent_at
      t.remove :remember_created_at
      t.remove :sign_in_count
      t.remove :current_sign_in_at
      t.remove :last_sign_in_at
      t.remove :current_sign_in_ip
      t.remove :last_sign_in_ip
    end
  end

  def down
    change_table :organisations do |t|
      t.string :email, null: false, default: ''
      t.string :encrypted_password, null: false, default: ''
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip
      t.index :email, unique: true
      t.index :reset_password_token, unique: true
    end
  end
end
