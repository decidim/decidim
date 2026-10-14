# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class counts all Followers of a participatory process or
    # participatory processes belonging to a participatory process group
    class ParticipatoryProcessesStatsFollowersCount < Decidim::StatsFollowersCount
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::ParticipatoryProcess) ||
                        (participatory_space.is_a?(Decidim::ParticipatoryProcessGroup) &&
                         participatory_space.participatory_processes.exists?)

        new(participatory_space).query
      end

      private

      def participatory_space_items
        @participatory_space_items ||= if participatory_space.is_a?(Decidim::ParticipatoryProcess)
                                         participatory_space
                                       else
                                         participatory_space.participatory_processes
                                       end
      end

      def space_components
        Decidim::Component.where(participatory_space: participatory_space_items).published
      end

      def space_query
        if participatory_space_items.is_a?(Decidim::ParticipatoryProcess)
          participatory_space_items.follows_count
        else
          participatory_space_items.sum(:follows_count)
        end
      end
    end
  end
end
