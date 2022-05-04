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
      statistics = []
      grouped_stats.each do |_manifest_name, stats|
        stats.each_with_index.each do |stat, _index|
          stat.each_with_index.map do |_item, subindex|
            next unless (subindex % 3).zero?
            next if stat[subindex + 2].zero?

            statistics << { stat_title: stat[subindex + 1], stat_number: stat[subindex + 2] }
          end
        end
      end
      statistics
    end
  end
end
