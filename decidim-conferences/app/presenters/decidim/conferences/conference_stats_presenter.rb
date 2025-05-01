# frozen_string_literal: true

module Decidim
  module Conferences
    # A presenter to render statistics in a Conference.
    class ConferenceStatsPresenter < Decidim::StatsPresenter
      include IconHelper

      private

      def scope_entity = __getobj__.fetch(:conference)
    end
  end
end
