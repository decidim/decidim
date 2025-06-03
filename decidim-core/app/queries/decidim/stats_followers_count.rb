# frozen_string_literal: true

module Decidim
  class StatsFollowersCount < Decidim::Query
    def initialize(participatory_space)
      @participatory_space = participatory_space
    end

    def query
      space_query + components_query
    end

    private

    attr_reader :participatory_space

    def components_query
      Decidim.component_manifests.sum do |component|
        component.stats
                 .filter(tag: :followers)
                 .with_context(space_components)
                 .map { |_name, value| value }
                 .compact_blank
                 .sum
      end
    end

    def space_query
      Decidim.participatory_space_manifests.sum do |space|
        space.stats
             .filter(tag: :followers)
             .with_context(participatory_space_items)
             .map { |_name, value| value }
             .compact_blank
             .sum
      end
    end

    def space_components
      @space_components ||= Decidim::Component.where(participatory_space:).published
    end
  end
end
