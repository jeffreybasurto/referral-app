ActiveAdmin.register Agent do
  config.sort_order = 'id_asc'
  actions :index, :show

  index do
    column :id
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

  show do
    attributes_table_for agent do
      row :email
      if agent.invitation_accepted_at.nil?
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
      end

      row 'Status' do |a|
        a.invitation_sent_at.nil? ? 'Joined (Link)' : a.invitation_accepted_at.nil? ? 'Pending' : 'Joined (Email)'
      end
    end
  end
end
