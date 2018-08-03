# frozen_string_literal: true

module Decidim
  # This module retrieves current loaded metrics, users, components or
  # participatory spaces
  module MetricEntity
    def self.metric_entities
      ["usersMetric"] |
        Decidim.component_manifests.map(&:metric_entities).flatten |
        Decidim.participatory_space_manifests.map(&:metric_entities).flatten
    end
  end
end
