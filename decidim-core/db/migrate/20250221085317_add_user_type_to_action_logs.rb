# frozen_string_literal: true

class AddUserTypeToActionLogs < ActiveRecord::Migration[7.0]
  class User < ApplicationRecord
    self.table_name = :decidim_users
    self.inheritance_column = nil # disable the default inheritance

    default_scope { where(type: "Decidim::User") }
  end

  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs
  end

  def up
    add_column :decidim_action_logs, :user_type, :string, default: "Decidim::User", null: false
    ActionLog.update_all(user_type: "Decidim::User") # rubocop:disable Rails/SkipsModelValidations

    rename_column :decidim_action_logs, :decidim_user_id, :user_id
    add_index :decidim_action_logs,
              [:user_id, :user_type],
              name: "index_decidim_action_log_on_users"
  end

  def down
    remove_index :decidim_action_logs, name: "index_decidim_action_log_on_users"
    rename_column :decidim_action_logs, :user_id, :decidim_user_id
    remove_column :decidim_action_logs, :user_type
  end
end
