# frozen_string_literal: true

module Decidim
  module Initiatives
    # This class counts all Followers of a initiative
    class InitiativesStatsFollowersCount < Decidim::StatsFollowersCount
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::Initiatives)

        new(participatory_space).query
      end

      private

      def participatory_space_items
        @participatory_space_items ||= (participatory_space if participatory_space.is_a?(Decidim::Initiatives))
      end
    end
  end
end
