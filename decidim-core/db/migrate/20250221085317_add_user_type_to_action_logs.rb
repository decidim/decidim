# frozen_string_literal: true

class AddUserTypeToActionLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_action_logs, :user_type, :string, default: "Decidim::User", null: false

    rename_column :decidim_action_logs, :decidim_user_id, :user_id
    add_index :decidim_action_logs,
              [:user_id, :user_type],
              name: "index_decidim_action_log_on_users"
  end
end
