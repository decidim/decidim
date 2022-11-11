# frozen_string_literal: true

module Decidim
  # A presenter to render statistics in the homepage.
  class HomeStatsPresenter < SimpleDelegator
    def organization
      __getobj__.fetch(:organization)
    end

    # Public: Render a collection of primary stats.
    def highlighted
      highlighted_stats = Decidim.stats.only([:users_count, :processes_count]).with_context(organization).map { |name, data| [name, data] }
      highlighted_stats.concat(global_stats(priority: StatsRegistry::HIGH_PRIORITY))
      highlighted_stats.concat(component_stats(priority: StatsRegistry::HIGH_PRIORITY))
      highlighted_stats = highlighted_stats.reject(&:empty?)
      highlighted_stats = highlighted_stats.reject { |_name, data| data.zero? }

      highlighted_stats.map do |name, data|
        { stat_title: name, stat_number: data }
      end
    end

    # Public: Render a collection of stats that are not primary.
    def not_highlighted
      not_highlighted_stats = global_stats(priority: StatsRegistry::MEDIUM_PRIORITY)
      not_highlighted_stats.concat(component_stats(priority: StatsRegistry::MEDIUM_PRIORITY))
      not_highlighted_stats = not_highlighted_stats.reject(&:empty?)
      not_highlighted_stats = not_highlighted_stats.reject { |_name, data| data.zero? }

      not_highlighted_stats.map do |name, data|
        { stat_title: name, stat_number: data }
      end
    end

    private

    def global_stats(conditions)
      Decidim.stats.except([:users_count, :processes_count, :followers_count])
             .filter(conditions)
             .with_context(organization)
             .map { |name, data| [name, data] }
    end

    def component_stats(conditions)
      stats = {}
      Decidim.component_manifests.flat_map do |component|
        component
          .stats.except([:supports_count])
          .filter(conditions)
          .with_context(published_components)
          .each do |name, data|
            stats[name] ||= 0
            stats[name] += data
          end
      end

      stats.to_a
    end

    def published_components
      @published_components ||= organization.published_components
    end
  end
end
