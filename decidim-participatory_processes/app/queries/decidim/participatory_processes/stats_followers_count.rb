# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class counts all Followers of a participatory processes
    class StatsFollowersCount < Rectify::Query
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a? Decidim::ParticipatoryProcess

        new(participatory_space).query
      end

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
                   .with_context(participatory_space.components.published)
                   .map { |_name, value| value }
                   .sum
        end
      end

      def space_query
        Decidim.participatory_space_manifests.sum do |space|
          space.stats
               .filter(tag: :followers)
               .with_context(participatory_space)
               .map { |_name, value| value }
               .sum
        end
      end
    end
  end
end
