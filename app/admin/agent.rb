ActiveAdmin.register Agent do
  config.sort_order = 'id_asc'
  actions :index, :show, :new, :create

  permit_params :bank_name, :insurance_company_name, :first_name, :last_name, :phone, :dob, :account_name,
                :account_number, :branch_name, :branch_address, :organisation_id, :email

  index do
    column :id
    column :agent_id
    column :email
    column 'Organisation ID' do |a|
      a.organisation_id
    end
    column :organisation_name
    column 'Status' do |a|
      a.invitation_sent_at.nil? ? 'Joined (Link)' : a.invitation_accepted_at.nil? ? 'Pending' : 'Joined (Email)'
    end
    actions
  end

  csv do
    config.sort_order = 'agent_id_asc'
    (Agent.column_names - %w(agent_id organisation_id)).each do |c|
      column c.to_sym
    end
    column 'Agent ID' do |a|
      a.agent_id
    end
    column 'Organisation ID' do |a|
      a.organisation_id
    end
    column :organisation_name
    column 'Status' do |a|
      a.invitation_sent_at.nil? ? 'Joined (Link)' : a.invitation_accepted_at.nil? ? 'Pending' : 'Joined (Email)'
    end
  end

  show do
    attributes_table_for agent do
      row :email
      if agent.invitation_accepted_at.nil? & agent.invitation_sent_at.present?
        row :invitation_token
        row :invitation_sent_at
      else
        row :first_name
        row :last_name
        row :phone
        row :dob
        row :insurance_company_name
        row :bank_name
        row :account_name
        row :branch_name
        row :branch_address
        row :account_number
        row :organisation_name
        row 'Organisation ID' do |a|
          a.organisation_id
        end
      end

      row 'Status' do |a|
        a.invitation_sent_at.nil? ? 'Joined (Link)' : a.invitation_accepted_at.nil? ? 'Pending' : 'Joined (Email)'
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Details' do
      f.input :organisation_id, as: :search_select, url: admin_organisations_path,
              fields: [:email, :name], display_name: 'name', minimum_input_length: 2
      f.input :email, as: :email, required: true
      f.input :password, required: true
      f.input :password_confirmation, required: true
      f.input :first_name, required: true
      f.input :last_name
      f.input :phone, as: :phone, required: true
      f.input :dob, as: :date_picker, required: true
      f.input :insurance_company_name, collection: Agent::INSURANCE_COMPANIES, required: true
      f.input :bank_name, as: :radio, collection: Agent::BANK_NAMES
      f.input :account_name
      f.input :branch_name
      f.input :branch_address
      f.input :account_number
    end

    actions
  end
end
