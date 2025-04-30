# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class counts unique Participants on a participatory process or
    # participatory processes belonging to a participatory process group
    class ParticipatoryProcessesStatsParticipantsCount < Decidim::StatsParticipantsCount
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::ParticipatoryProcess) ||
                        (participatory_space.is_a?(Decidim::ParticipatoryProcessGroup) &&
                         participatory_space.participatory_processes.exists?)

        new(participatory_space).query
      end

      private

      def participatory_space_ids
        @participatory_space_ids ||= if participatory_space.is_a?(Decidim::ParticipatoryProcess)
                                       participatory_space.id
                                     else
                                       participatory_space.participatory_processes.pluck(:id)
                                     end
      end

      def participatory_space_class
        Decidim::ParticipatoryProcess
      end

      def space_components
        @space_components ||= if participatory_space.is_a?(Decidim::ParticipatoryProcess)
                                participatory_space.components
                              else
                                Decidim::Component.where(participatory_space: participatory_space.participatory_processes)
                              end
      end
    end
  end
end
