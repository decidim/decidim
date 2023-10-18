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

    # Public: returns a collection of stats (Hash) for the Participatory Space Home.
    def collection
      highlighted_stats = participatory_space_participants_stats
      highlighted_stats.concat(participatory_space_followers_stats(priority: StatsRegistry::HIGH_PRIORITY))
      highlighted_stats.concat(component_stats(priority: StatsRegistry::HIGH_PRIORITY))
      highlighted_stats.concat(component_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
      highlighted_stats.concat(comments_stats(participatory_space_sym))
      highlighted_stats = highlighted_stats.reject(&:empty?)
      highlighted_stats = highlighted_stats.reject { |_stat_manifest, _stat_title, stat_number| stat_number.zero? }
      grouped_highlighted_stats = highlighted_stats.group_by(&:first)

      statistics(grouped_highlighted_stats)
    end

    def card_collection
      card_stats = Decidim.stats.only([:followers_count, :votings_count])
                          .filter(priority: StatsRegistry::HIGH_PRIORITY)
                          .with_context(participatory_space)
                          .map { |stat_title, stat_number| [participatory_space_sym, stat_title, stat_number] }

      statistics(card_stats.group_by(&:first))
    end

    private

    def participatory_space = raise "Not implemented"

    def participatory_space_sym = raise "Not implemented"

    def participatory_space_participants_stats
      Decidim.stats.only([:participants_count]).with_context(participatory_space)
             .map { |stat_title, stat_number| [participatory_space_sym, stat_title, stat_number] }
    end

    def component_stats(conditions)
      Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats.except([:proposals_accepted])
                          .filter(conditions)
                          .with_context(published_components)
                          .map { |stat_title, stat_number| [component_manifest.name, stat_title, stat_number] }.flatten
      end
    end

    def participatory_space_followers_stats(conditions)
      Decidim.stats.only([:followers_count])
             .filter(conditions)
             .with_context(participatory_space)
             .map { |stat_title, stat_number| [participatory_space_sym, stat_title, stat_number] }
    end

    def published_components
      @published_components ||= Component.where(participatory_space:).published
    end
  end
end
