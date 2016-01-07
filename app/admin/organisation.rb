ActiveAdmin.register Organisation do
  config.sort_order = 'id_asc'
  permit_params :name, :test

  index do
    column :id
    column :name
    column 'Emails sent' do |org|
      org.total_mails_sent
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
      org.total_ref_link_generated_count
    end
    column :test

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :name
      f.input :test, as: :boolean
    end

    actions
  end

  csv do
    (Organisation.column_names - %w(ref_link_generated_count mails_sent)).each do |c|
      column c.to_sym
    end
    column 'Emails sent' do |org|
      org.total_mails_sent
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
      org.total_ref_link_generated_count
    end
    column :test
  end

  filter :name

  show do
    attributes_table do
      row :name
      row :test
    end

    paginated_collection organisation.agents.page(params[:page]).per(10), download_links: false do
      table_for collection, sortable: false do
        column :id
        column 'Agent ID', :agent_id
        column :email
        column 'Status' do |a|
          if a.invited_by.nil?
            'Joined (Sign up)'
          elsif a.invitation_sent_at.nil?
            'Joined (Link)'
          elsif a.invitation_accepted_at.nil?
            'Pending'
          else
            'Joined (Email)'
          end
        end
        column 'Actions' do |a|
          "#{link_to 'View agent', admin_agent_path(a.id)}&nbsp;&nbsp;#{link_to 'Edit agent', edit_admin_agent_path(a.id)}".html_safe
        end
      end
    end
  end

  sidebar 'Stats', only: :show do
    attributes_table do
      row 'Emails sent' do |org|
        org.total_mails_sent
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
        org.total_ref_link_generated_count
      end
    end
  end
end
