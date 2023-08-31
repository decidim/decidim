# frozen_string_literal: true

module Decidim
  module Conferences
    # A presenter to render statistics in a Conference.
    class ConferenceStatsPresenter < Decidim::StatsPresenter
      include IconHelper

      def conference
        __getobj__.fetch(:conference)
      end

      def participatory_space
        conference
      end

      def participatory_space_sym
        :conferences
      end
    end
  end
end
