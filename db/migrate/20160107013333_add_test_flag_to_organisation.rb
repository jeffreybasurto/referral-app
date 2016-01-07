class AddTestFlagToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :test, :boolean, default: false
  end
end
