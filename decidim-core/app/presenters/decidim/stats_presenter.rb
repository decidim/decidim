# frozen_string_literal: true

module Decidim
  # A general presenter to render statistics in participatory spaces.
  class StatsPresenter < SimpleDelegator
    def comments_stats(name)
      comments = Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats.only([:comments_count])
                          .filter({ tag: :comments })
                          .with_context(published_components)
                          .map { |_name, value| value }.sum
      end
      comments_count = comments.inject(0, :+) { |sum, value| sum + value }
      [[name, :comments_count, comments_count]]
    end

    def statistics(grouped_stats)
      statistics = {}

      grouped_stats.each do |_manifest_name, stats|
        stats.each do |_space_manifest, component_manifest, count|
          next if count.zero?

          statistics[component_manifest] ||= 0
          statistics[component_manifest] += count
        end
      end
      statistics.map { |key, number| { stat_title: key, stat_number: number } }
    end
  end
end
