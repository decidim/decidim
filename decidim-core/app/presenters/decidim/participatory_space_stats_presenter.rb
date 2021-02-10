# frozen_string_literal: true

module Decidim
  # A presenter to render statistics in a Participatory Space.
  class ParticipatorySpaceStatsPresenter < Rectify::Presenter
    attribute :space
    include Decidim::IconHelper

    # Public: returns a collection of stats (Hash) for the Participatory Space Home.
    def collection
      highlighted_stats = space_participants_stats
      highlighted_stats.concat(space_followers_stats(priority: StatsRegistry::HIGH_PRIORITY))
      highlighted_stats.concat(component_stats(priority: StatsRegistry::HIGH_PRIORITY))
      highlighted_stats.concat(component_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
      highlighted_stats = highlighted_stats.reject(&:empty?)
      highlighted_stats = highlighted_stats.reject { |_stat_manifest, _stat_title, stat_number| stat_number.zero? }
      grouped_highlighted_stats = highlighted_stats.group_by(&:first)

      statistics = []
      grouped_highlighted_stats.each do |_manifest_name, stats|
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

    private

    def space_participants_stats
      Decidim.stats.only([:participants_count]).with_context(space)
             .map { |stat_title, stat_number| [space.manifest.name, stat_title, stat_number] }
    end

    def component_stats(conditions)
      Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats.except([:proposals_accepted])
                          .filter(conditions)
                          .with_context(published_components)
                          .map { |stat_title, stat_number| [component_manifest.name, stat_title, stat_number] }.flatten
      end
    end

    def space_followers_stats(conditions)
      Decidim.stats.only([:followers_count])
             .filter(conditions)
             .with_context(space)
             .map { |stat_title, stat_number| [space.manifest.name, stat_title, stat_number] }
    end

    def published_components
      @published_components ||= Component.where(participatory_space: space).published
    end
  end
end
