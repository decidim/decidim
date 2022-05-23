# frozen_string_literal: true

class AddPreviousPasswordsToUsers < ActiveRecord::Migration[6.1]
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end

  def up
    add_column :decidim_users, :password_updated_at, :datetime
    add_column :decidim_users, :previous_passwords, :string, array: true, default: []

    User.find_each do |user|
      next unless user.admin

      user.password_updated_at = user.updated_at
      user.save
    end
  end

  def down
    remove_column :decidim_users, :password_updated_at
    remove_column :decidim_users, :previous_passwords
  end
end
