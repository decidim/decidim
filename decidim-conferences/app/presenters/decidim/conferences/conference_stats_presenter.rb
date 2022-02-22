# frozen_string_literal: true

module Decidim
  module Conferences
    # A presenter to render statistics in the homepage.
    class ConferenceStatsPresenter < Decidim::StatsPresenter
      include IconHelper

      def conference
        __getobj__.fetch(:conference)
      end

      # Public: Render a collection of primary stats.
      def highlighted
        highlighted_stats = component_stats(priority: StatsRegistry::HIGH_PRIORITY)
        highlighted_stats.concat(component_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
        highlighted_stats.concat(comments_stats(:conferences))
        highlighted_stats = highlighted_stats.reject(&:empty?)
        highlighted_stats = highlighted_stats.reject { |_manifest, _name, data| data.zero? }
        grouped_highlighted_stats = highlighted_stats.group_by(&:first)

        statistics(grouped_highlighted_stats)
      end

      private

      def component_stats(conditions)
        Decidim.component_manifests.map do |component_manifest|
          component_manifest.stats
                            .filter(conditions)
                            .with_context(published_components)
                            .map { |name, data| [component_manifest.name, name, data] }.flatten
        end
      end

      def published_components
        @published_components ||= Component.where(participatory_space: conference).published
      end
    end
  end
end
