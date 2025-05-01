# frozen_string_literal: true

module Decidim
  module Assemblies
    # This class counts all Followers of a assembly
    class AssembliesStatsFollowersCount < Decidim::StatsFollowersCount
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::Assemblies)

        new(participatory_space).query
      end
    end
  end
end
