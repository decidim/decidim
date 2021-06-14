# frozen_string_literal: true

module Decidim
  module Conferences
    # A presenter to render statistics in the homepage.
    class ConferenceStatsPresenter < Rectify::Presenter
      attribute :conference, Decidim::Conference
      include IconHelper

      # Public: Render a collection of primary stats.
      def highlighted
        highlighted_stats = component_stats(priority: StatsRegistry::HIGH_PRIORITY)
        highlighted_stats.concat(component_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
        highlighted_stats = highlighted_stats.reject(&:empty?)
        highlighted_stats = highlighted_stats.reject { |_name, data| data.zero? }

        highlighted_stats.map do |name, data|
          { stat_title: name, stat_number: data }
        end
      end

      private

      def component_stats(conditions)
        Decidim.component_manifests.map do |component_manifest|
          component_manifest.stats
                            .filter(conditions)
                            .with_context(published_components)
                            .map { |name, data| [name, data] }.flatten
        end
      end

      def published_components
        @published_components ||= Component.where(participatory_space: conference).published
      end
    end
  end
end
