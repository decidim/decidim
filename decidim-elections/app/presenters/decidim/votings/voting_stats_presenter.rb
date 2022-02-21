# frozen_string_literal: true

module Decidim
  module Votings
    # A presenter to render statistics in the homepage.
    class VotingStatsPresenter < Decidim::StatsPresenter
      include Decidim::IconHelper

      def voting
        __getobj__.fetch(:voting)
      end

      # Public: returns a collection of stats (Hash) for the Voting Landing.
      def collection
        highlighted_stats = voting_participants_stats
        highlighted_stats.concat(voting_followers_stats(priority: StatsRegistry::HIGH_PRIORITY))
        highlighted_stats.concat(component_stats(priority: StatsRegistry::HIGH_PRIORITY))
        highlighted_stats.concat(component_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
        highlighted_stats.concat(comments_stats(:votings))
        highlighted_stats = highlighted_stats.reject(&:empty?)
        highlighted_stats = highlighted_stats.reject { |_stat_manifest, _stat_title, stat_number| stat_number.zero? }
        grouped_highlighted_stats = highlighted_stats.group_by(&:first)

        statistics(grouped_highlighted_stats)
      end

      private

      def voting_participants_stats
        Decidim.stats.only([:participants_count]).with_context(voting)
               .map { |stat_title, stat_number| [voting.manifest.name, stat_title, stat_number] }
      end

      def component_stats(conditions)
        Decidim.component_manifests.map do |component_manifest|
          component_manifest.stats.except([:proposals_accepted])
                            .filter(conditions)
                            .with_context(published_components)
                            .map { |stat_title, stat_number| [component_manifest.name, stat_title, stat_number] }.flatten
        end
      end

      def voting_followers_stats(conditions)
        Decidim.stats.only([:followers_count])
               .filter(conditions)
               .with_context(voting)
               .map { |stat_title, stat_number| [voting.manifest.name, stat_title, stat_number] }
      end

      def published_components
        @published_components ||= Component.where(participatory_space: voting).published
      end
    end
  end
end
