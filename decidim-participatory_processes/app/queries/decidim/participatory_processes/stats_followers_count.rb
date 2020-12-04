# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class counts all Followers of a participatory process or
    # participatory processes belonging to a participatory process group
    class StatsFollowersCount < Rectify::Query
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::ParticipatoryProcess) ||
                        participatory_space.is_a?(Decidim::ParticipatoryProcessGroup) && participatory_space.participatory_processes.exists?

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
                   .with_context(space_components)
                   .map { |_name, value| value }
                   .sum
        end
      end

      def space_query
        Decidim.participatory_space_manifests.sum do |space|
          space.stats
               .filter(tag: :followers)
               .with_context(participatory_space_items)
               .map { |_name, value| value }
               .sum
        end
      end

      def participatory_space_items
        @participatory_space_items ||= if participatory_space.is_a?(Decidim::ParticipatoryProcess)
                                         participatory_space
                                       else
                                         participatory_space.participatory_processes
                                       end
      end

      def space_components
        @space_components ||= Decidim::Component.where(participatory_space: participatory_space_items).published
      end
    end
  end
end
