# frozen_string_literal: true

module Decidim
  module Assemblies
    # This class counts all Followers of a assembly
    class AssembliesStatsFollowersCount < Decidim::StatsFollowersCount
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::Assemblies)

        new(participatory_space).query
      end

      private

      def participatory_space_items
        @participatory_space_items ||= (participatory_space if participatory_space.is_a?(Decidim::Assemblies))
      end
    end
  end
end
