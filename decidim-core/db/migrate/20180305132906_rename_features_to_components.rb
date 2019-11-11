# frozen_string_literal: true

class RenameFeaturesToComponents < ActiveRecord::Migration[5.1]
  class ActionLog < ApplicationRecord
    self.table_name = :decidim_action_logs
  end

  class Version < ApplicationRecord
    self.table_name = :versions
  end

  def change
    rename_table :decidim_features, :decidim_components
    rename_column :decidim_action_logs, :decidim_feature_id, :decidim_component_id
    rename_index :decidim_action_logs, "index_action_logs_on_feature_id", "index_action_logs_on_component_id"

    if index_name_exists?(:decidim_components, "index_decidim_features_on_decidim_participatory_space")
      rename_index :decidim_components, "index_decidim_features_on_decidim_participatory_space", "index_decidim_components_on_decidim_participatory_space"
    end

    # rubocop:disable Rails/SkipsModelValidations
    Version.where(item_type: "Decidim::Feature").update_all(item_type: "Decidim::Component")
    ActionLog.where(resource_type: "Decidim::Feature").update_all(resource_type: "Decidim::Component")
    # rubocop:enable Rails/SkipsModelValidations

    ActionLog.find_each do |log|
      new_extra = log.extra.dup
      next if new_extra["component"].present?

      new_extra["component"] = new_extra["feature"]
      new_extra.delete("feature")
      log.extra = new_extra
      log.save!
    end
  end
end
