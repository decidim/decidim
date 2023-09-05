# frozen_string_literal: true

module Decidim
  module Conferences
    # A presenter to render statistics in a Conference.
    class ConferenceStatsPresenter < Decidim::StatsPresenter
      include IconHelper

      private

      def participatory_space = __getobj__.fetch(:conference)

      def participatory_space_sym = :conferences
    end
  end
end
