ActiveAdmin.register Agent do
  config.sort_order = 'id_asc'

  permit_params :bank_name, :insurance_company_name, :first_name, :last_name, :phone, :dob, :account_name, :invited_by_id,
                :account_number, :branch_name, :branch_address, :organisation_id, :email, :password, :password_confirmation

  member_action :autocomplete_invited_by, method: :get do
    current_agent = Agent.find(params[:id])

    agents = current_agent.organisation.agents_excluding(current_agent).where('lower(email) LIKE LOWER(?)', "%#{params[:term]}%")

    render json: agents.map { |a| { id: a.id, label: a.email, value: a.email } }
  end

  collection_action :process_csv_import, method: :post do
    uploaded_csv = params[:agent][:csv]
    file_name = Rails.root.join('tmp', uploaded_csv.original_filename)
    File.open(file_name, 'wb') do |file|
      file.write(uploaded_csv.read)
    end
    result = Agent.import_csv(file_name)

    if result[:success]
      redirect_to csv_import_admin_agents_path, notice: 'Imported successfully.'
    else
      @invalid_rows = result[:invalid_rows]
      @page_title = 'CSV Import Errors'
      render 'csv_errors', layout: 'active_admin'
    end
  end

  collection_action :csv_import, method: :get do
    render 'csv_import', layout: 'active_admin'
  end

  controller do
    def scoped_collection
      super.includes :organisation, :invited_by
    end

    before_save do |agent|
      if agent.invited_by_id.present?
        agent.invited_by_type = 'Agent'
      else
        agent.invited_by_type = nil
      end
    end
  end

  action_item :only => :index do
    link_to('Import CSV', csv_import_admin_agents_path)
  end

  index do
    column :id
    column 'Inviter' do |a|
      if a.invited_by.present?
        link_to "#{a.invited_by.name} (#{a.invited_by.email})", admin_agent_path(a.invited_by)
      else
        'None'
      end
    end
    column 'Agent ID', :agent_id
    column :email
    column 'Organisation ID' do |a|
      a.organisation_id
    end
    column :organisation_name
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

    # column :email
    # column :first_name
    # column :last_name
    # column :phone
    # column :dob
    # column :insurance_company_name
    # column :bank_name
    # column :account_name
    # column :branch_name
    # column :branch_address
    # column :account_number
  end

  show do
    attributes_table_for agent do
      row :email
      row 'Inviter' do |a|
        if a.invited_by.present?
          link_to "#{a.invited_by.name} (#{a.invited_by.email})", admin_agent_path(a.invited_by)
        else
          'None'
        end
      end
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
        row :referral_token
        row :locale
      end

      row 'Status' do |a|
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
    end

    panel 'Invited agents' do
      paginated_collection agent.invitations.page(params[:page]).per(10), download_links: false do
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
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs 'Details' do
      if agent.persisted?
        f.input :invited_by_email, as: :autocomplete, url: autocomplete_invited_by_admin_agent_path(agent)
      else
        f.input :organisation_id, as: :search_select, url: admin_organisations_path,
                fields:               [:name], display_name: 'name', minimum_input_length: 2
      end
      f.input :invited_by_id, as: :hidden, required: true, input_html: { 'data-default-value' => agent.invited_by_id }
      f.input :email, as: :email, required: true
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
    f.template.render partial: 'js'
  end

  sidebar 'Stats', only: :show do
    render partial: 'csv_import_form', locals: { agent: agent }
  end
end
