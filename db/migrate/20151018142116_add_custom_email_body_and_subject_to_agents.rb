class AddCustomEmailBodyAndSubjectToAgents < ActiveRecord::Migration
  def change
    add_column :agents, :invite_email_subject, :string
    add_column :agents, :invite_email_body, :text
  end
end
