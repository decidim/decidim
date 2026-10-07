# frozen_string_literal: true

class MakeUserOptionalInActionLogs < ActiveRecord::Migration[8.1]
  def change
    change_column_null :decidim_action_logs, :user_id, true
    change_column_null :decidim_action_logs, :user_type, true
  end
end
