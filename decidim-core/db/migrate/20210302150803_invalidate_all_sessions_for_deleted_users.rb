# frozen_string_literal: true

class InvalidateAllSessionsForDeletedUsers < ActiveRecord::Migration[5.2]
  def up
    Decidim::User.reset_column_information

    Decidim::User.where.not(deleted_at: nil).find_each(&:invalidate_all_sessions!)
  end

  def down; end
end
