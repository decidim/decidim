# frozen_string_literal: true

module Decidim
  # A presenter to render statistics in the homepage.
  class HomeStatsPresenter < SimpleDelegator
    def organization
      __getobj__.fetch(:organization)
    end

    # Public: Render a collection of primary stats.
    def aggregated_stats(priority: StatsRegistry::HIGH_PRIORITY)
      stats = all_stats(priority:).reject(&:empty?)
      stats = stats.reject { |stat| stat[:data].blank? || stat[:data][0].zero? }
      stats.each_with_object({}) do |stat, hash|
        name = stat[:name]
        if hash[name]
          stat[:data].each_with_index do |value, idx|
            hash[name][:data][idx] ||= 0
            hash[name][:data][idx] += value
          end
        else
          hash[name] = stat
        end
      end.values
    end

    def all_stats(conditions)
      @global_stats ||= global_stats(**conditions).concat(component_stats(**conditions))
    end

    private

    def global_stats(conditions)
      Decidim.stats.filter(**conditions).with_context(organization).map do |stat|
        stat[:data] = [stat[:data]] unless stat[:data].is_a?(Array)
        stat
      end
    end

    def component_stats(conditions)
      Decidim.component_manifests.flat_map do |component|
        component
          .stats.except([:proposals_accepted])
          .filter(conditions)
          .with_context(published_components)
          .map do |stat|
            stat[:data] = [stat[:data]] unless stat[:data].is_a?(Array)
            stat
          end
      end
    end

    def published_components
      @published_components ||= organization.published_components
    end
  end
end
