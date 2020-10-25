# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class StatsCell < Decidim::ViewModel
      def stats
        @stats ||= HomeStatsPresenter.new(organization: current_organization)
      end
    end
  end
end
