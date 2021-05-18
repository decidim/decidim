# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # A presenter to render statistics in the homepage.
    class ParticipatoryProcessGroupStatsPresenter < Decidim::StatsPresenter
      attribute :participatory_process_group, Decidim::ParticipatoryProcessGroup
      include Decidim::IconHelper

      # Public: returns a collection of stats (Hash) for the participatory
      # process group landing page.
      def collection
        highlighted_stats = process_participants_stats
        highlighted_stats.concat(process_followers_stats(priority: StatsRegistry::HIGH_PRIORITY))
        highlighted_stats.concat(component_stats(priority: StatsRegistry::HIGH_PRIORITY))
        highlighted_stats.concat(component_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
        highlighted_stats.concat(comments_stats(:participatory_processes, tag: :comments))
        highlighted_stats = highlighted_stats.reject(&:empty?)
        highlighted_stats = highlighted_stats.reject { |_stat_manifest, _stat_title, stat_number| stat_number.zero? }
        grouped_highlighted_stats = highlighted_stats.group_by(&:first)

        statistics(grouped_highlighted_stats)
      end

      private

      def process_participants_stats
        Decidim.stats.only([:participants_count]).with_context(participatory_process_group)
               .map { |stat_title, stat_number| [:participatory_process_group, stat_title, stat_number] }
      end

      def component_stats(conditions)
        Decidim.component_manifests.map do |component_manifest|
          component_manifest.stats.except([:proposals_accepted])
                            .filter(conditions)
                            .with_context(published_components)
                            .map { |stat_title, stat_number| [component_manifest.name, stat_title, stat_number] }.flatten
        end
      end

      def process_followers_stats(conditions)
        Decidim.stats.only([:followers_count])
               .filter(conditions)
               .with_context(participatory_process_group)
               .map { |stat_title, stat_number| [:participatory_process_group, stat_title, stat_number] }
      end

      def participatory_processes
        @participatory_processes ||= participatory_process_group.participatory_processes
      end

      def published_components
        @published_components ||= Component.where(participatory_space: participatory_processes).published
      end
    end
  end
end
