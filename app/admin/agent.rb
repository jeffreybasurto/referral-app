ActiveAdmin.register Agent do
  actions :index, :show

  index do
    column :email
    column :organisation_name
    column 'Status' do |a|
      a.invitation_accepted_at.nil? ? 'Pending' : 'Joined'
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
        a.invitation_accepted_at.nil? ? 'Pending' : 'Joined'
      end
    end
  end
end
