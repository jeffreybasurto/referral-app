class AddBulkUploadFlagToAgents < ActiveRecord::Migration
  def up
    add_column :agents, :bulk_upload, :boolean, default: false

    Agent.find_each do |a|
      a.update_column(:bulk_upload, false)
    end
  end

  def down
    remove_column :agents, :bulk_upload
  end
end
