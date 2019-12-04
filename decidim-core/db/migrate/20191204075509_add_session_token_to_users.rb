class AddSessionTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_users, :session_token, :string
  end
end
