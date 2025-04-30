# frozen_string_literal: true

module Decidim
  module Conferences
    # This class counts all Followers of a conference
    class ConferencesStatsFollowersCount < Decidim::StatsFollowersCount
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::Conferences)

        new(participatory_space).query
      end

      private

      def participatory_space_items
        @participatory_space_items ||= (participatory_space if participatory_space.is_a?(Decidim::Conferences))
      end
    end
  end
end
