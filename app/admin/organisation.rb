ActiveAdmin.register Organisation do
  permit_params :name, :email, :password, :password_confirmation

  actions :index, :show

  index do
    column :name
    column :email
    column :referral_token
    actions
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
      row 'Agents invited via email' do
        organisation.invitations_sent.count
      end
      row 'Agents joined via email' do
        organisation.invitations_accepted.count
      end
      row 'Agents joined via referral link' do
        organisation.agents_via_ref_link.count
      end
      row 'Referral links generated' do
        organisation.ref_link_generated_count
      end
    end
  end
end
