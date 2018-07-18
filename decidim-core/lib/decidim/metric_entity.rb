# frozen_string_literal: true

module Decidim
  module MetricEntity
    def self.metric_entities
      ["usersMetric"] |
        Decidim.component_manifests.map(&:metric_entities).flatten |
        Decidim.participatory_space_manifests.map(&:metric_entities).flatten # |
      # (Decidim::Comments.metric_entities.flatten if defined?(Decidim::Comments))
    end
  end
end
