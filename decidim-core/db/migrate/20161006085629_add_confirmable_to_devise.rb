# frozen_string_literal: true

class AddConfirmableToDevise < ActiveRecord::Migration[5.0]
  def up
    add_column :decidim_users, :confirmation_token, :string
    add_column :decidim_users, :confirmed_at, :datetime
    add_column :decidim_users, :confirmation_sent_at, :datetime
    add_column :decidim_users, :unconfirmed_email, :string
    add_index :decidim_users, :confirmation_token, unique: true
    execute("UPDATE decidim_users SET confirmed_at = NOW()")
  end

  def down
    remove_columns :decidim_users, :confirmation_token, :confirmed_at, :confirmation_sent_at
  end
end
