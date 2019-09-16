# frozen_string_literal: true

class AddUniqIndexToDecidimMetrics < ActiveRecord::Migration[5.2]
  def change
    add_index(
      :decidim_metrics, [
        :day,
        :metric_type,
        :decidim_organization_id,
        :participatory_space_type,
        :participatory_space_id,
        :related_object_type,
        :related_object_id,
        :decidim_category_id
      ],
      unique: true,
      name: "idx_metric_by_day_type_org_space_object_category"
    )
  end
end
