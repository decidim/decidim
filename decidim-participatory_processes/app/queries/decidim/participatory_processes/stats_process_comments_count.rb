# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This class counts unique Participants on a participatory process or
    # participatory processes belonging to a participatory process group
    class StatsProcessCommentsCount < Rectify::Query
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::ParticipatoryProcess) ||
                        participatory_space.is_a?(Decidim::ParticipatoryProcessGroup) && participatory_space.participatory_processes.exists?

        new(participatory_space).query
      end

      def initialize(participatory_space)
        @participatory_space = participatory_space
      end

      def query
        [
          comments_meetings,
          comments_proposals
        ].collect(&:to_i).inject(0, :+)
      end

      private

      attr_reader :participatory_space

      def participatory_space_ids
        @participatory_space_ids ||= if participatory_space.is_a?(Decidim::ParticipatoryProcess)
                                       participatory_space.id
                                     else
                                       participatory_space.participatory_processes.pluck(:id)
                                     end
      end

      def comments_meetings
        Decidim::Meetings::Meeting.joins(:component).where(decidim_components: {participatory_space_id: participatory_space_ids}).sum(:comments_count)
      end

      def comments_proposals
        Decidim::Proposals::Proposal.joins(:component).where(decidim_components: {participatory_space_id: participatory_space_ids}).sum(:comments_count)
      end
    end
  end
end
