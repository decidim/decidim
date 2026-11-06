# frozen_string_literal: true

class MakeUserOptionalInActionLogs < ActiveRecord::Migration[8.1]
  def up
    change_column_null :decidim_action_logs, :user_id, true
    change_column_null :decidim_action_logs, :user_type, true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
