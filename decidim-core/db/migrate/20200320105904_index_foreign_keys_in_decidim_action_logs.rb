# frozen_string_literal: true

class IndexForeignKeysInDecidimActionLogs < ActiveRecord::Migration[5.2]
  def change
    add_index :decidim_action_logs, :decidim_area_id
    add_index :decidim_action_logs, :decidim_scope_id
    add_index :decidim_action_logs, :version_id
  end
end
