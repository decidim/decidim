class AddVersionToActionLogs < ActiveRecord::Migration[5.1]
  def up
    add_column :decidim_action_logs, :version_id, :integer, index: true

    Decidim::ActionLog.find_each do |action_log|
      version_id = action_log.extra.dig("version", "id")
      next unless version_id
      action_log.update_column(:version_id, version_id)
    end
  end

  def down
    remove_column :decidim_action_logs, :version_id
  end
end
