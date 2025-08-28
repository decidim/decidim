# frozen_string_literal: true

module Decidim
  # A general presenter to render statistics in participatory spaces.
  class StatsPresenter < SimpleDelegator
    # Public: returns a collection of stats (Hash) for the Participatory Space Home.
    def collection(priority: StatsRegistry::MEDIUM_PRIORITY)
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
      @global_stats ||= {}
      @global_stats[conditions] ||= global_stats(**conditions).concat(component_stats(**conditions))
    end

    # Public: returns the entity where to limit the stats on.
    # Usually, this is a Participatory Space or an Organization.
    def scope_entity = raise NotImplementedError

    private

    def global_stats(conditions)
      Decidim.stats.filter(**conditions).with_context(scope_entity).map do |stat|
        stat[:data] = [stat[:data]] unless stat[:data].is_a?(Array)
        stat
      end
    end

    def component_stats(conditions)
      Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats
                          .filter(conditions)
                          .with_context(published_components)
                          .map do |stat|
                            stat[:data] = [stat[:data]] unless stat[:data].is_a?(Array)
                            stat
                          end
      end.flatten
    end

    # Override if the scope_entity is not a Participatory Space or an Organization.
    def published_components
      @published_components ||= if scope_entity.is_a?(Decidim::Organization)
                                  scope_entity.published_components
                                elsif scope_entity.is_a?(Decidim::ParticipatoryProcessGroup)
                                  Component.where(participatory_space: scope_entity.participatory_processes).published
                                else
                                  Component.where(participatory_space: scope_entity).published
                                end
    end
  end
end
