# frozen_string_literal: true

module Decidim
  module Assemblies
    # This class counts unique Participants on a assembly
    class AssembliesStatsParticipantsCount < Decidim::StatsParticipantsCount
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::Assemblies)

        new(participatory_space).query
      end

      private

      def participatory_space_ids
        @participatory_space_ids ||= (participatory_space.id if participatory_space.is_a?(Decidim::Assemblies))
      end

      def participatory_space_class
        Decidim::Assembly
      end
    end
  end
end
