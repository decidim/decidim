# frozen_string_literal: true

module Decidim
  module Conferences
    # This class counts unique Participants on a conference
    class ConferencesStatsParticipantsCount < Decidim::StatsParticipantsCount
      def self.for(participatory_space)
        return 0 unless participatory_space.is_a?(Decidim::Conferences)

        new(participatory_space).query
      end
    end
  end
end
