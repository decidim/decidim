class AddReconfirmableToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_users, :unconfirmed_email, :string
  end
end
