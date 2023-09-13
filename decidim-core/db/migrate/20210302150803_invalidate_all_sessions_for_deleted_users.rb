# frozen_string_literal: true

class InvalidateAllSessionsForDeletedUsers < ActiveRecord::Migration[5.2]
  class User < ApplicationRecord
    self.table_name = "decidim_users"
    self.inheritance_column = nil # disable the default inheritance

    default_scope { where(type: "Decidim::User") }
  end

  def up
    User.where.not(deleted_at: nil).find_each do |user|
      user.update!(session_token: SecureRandom.hex)
    end
  end

  def down; end
end
