ActiveAdmin.register Organisation do
  config.sort_order = 'id_asc'
  permit_params :name, :email, :password, :password_confirmation

  index do
    column :id
    column :name
    column 'Emails sent' do |org|
      org.mails_sent
    end
    column 'Unique emails sent' do |org|
      org.unique_mails_sent
    end
    column 'Number of pending agents' do |org|
      org.invitations_pending
    end
    column 'Number of agents joined (email)' do |org|
      org.invitations_accepted
    end
    column 'Number of agents joined (link)' do |org|
      org.agents_via_ref_link
    end
    column 'Referral links generated' do |org|
      org.ref_link_generated_count
    end

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :name
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
  end

  csv do
    (Organisation.column_names - %w(ref_link_generated_count mails_sent)).each do |c|
      column c.to_sym
    end
    column 'Emails sent' do |org|
      org.mails_sent
    end
    column 'Unique emails sent' do |org|
      org.unique_mails_sent
    end
    column 'Number of pending agents' do |org|
      org.agents.invitation_not_accepted.count
    end
    column 'Number of agents joined (email)' do |org|
      org.invitations_accepted
    end
    column 'Number of agents joined (link)' do |org|
      org.agents_via_ref_link
    end
    column 'Referral links generated' do |org|
      org.ref_link_generated_count
    end
  end

  filter :email
  filter :name

  show do
    attributes_table do
      row :name
      row :email
      row :referral_token
      row :locale
    end
  end

  sidebar 'Stats', only: :show do
    attributes_table do
      row 'Emails sent' do |org|
        org.mails_sent
      end
      row 'Unique emails sent' do |org|
        org.unique_mails_sent
      end
      row 'Number of pending agents' do |org|
        org.agents.invitation_not_accepted.count
      end
      row 'Number of agents joined (email)' do |org|
        org.invitations_accepted
      end
      row 'Number of agents joined (link)' do |org|
        org.agents_via_ref_link
      end
      row 'Referral links generated' do |org|
        org.ref_link_generated_count
      end
    end
  end
end
