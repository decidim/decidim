# This migration comes from decidim (originally 20161010131544)
# frozen_string_literal: true

class AddLocaleToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :decidim_users, :locale, :string
  end
end
