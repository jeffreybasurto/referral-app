class AddLocaleToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :locale, :string
  end
end
