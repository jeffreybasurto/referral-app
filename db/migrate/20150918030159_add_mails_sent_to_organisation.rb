class AddMailsSentToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :mails_sent, :integer, default: 0
  end
end
