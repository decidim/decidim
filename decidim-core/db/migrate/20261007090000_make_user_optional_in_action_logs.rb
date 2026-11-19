# frozen_string_literal: true

class MakeUserOptionalInActionLogs < ActiveRecord::Migration[7.2]
  def up
    change_column_null :decidim_action_logs, :user_id, true
    change_column_null :decidim_action_logs, :user_type, true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
