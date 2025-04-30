# frozen_string_literal: true

module Decidim
  module Initiatives
    # This class counts unique Participants on a initiative
    class InitiativesStatsParticipantsCount < Decidim::StatsParticipantsCount
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::Initiatives)

        new(participatory_space).query
      end

      private

      def participatory_space_ids
        @participatory_space_ids ||= (participatory_space.id if participatory_space.is_a?(Decidim::Initiatives))
      end

      def participatory_space_class
        Decidim::Initiative
      end
    end
  end
end
