# frozen_string_literal: true

class AddPreviousPasswordsToUsers < ActiveRecord::Migration[6.1]
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end

  def change
    add_column :decidim_users, :password_updated_at, :datetime
    add_column :decidim_users, :previous_passwords, :string, array: true, default: []

    reversible do |direction|
      direction.up do
        # rubocop:disable Rails/SkipsModelValidations
        User.update_all("password_updated_at = updated_at")
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
