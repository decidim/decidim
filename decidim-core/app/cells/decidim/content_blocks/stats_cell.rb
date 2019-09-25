# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class StatsCell < Decidim::ViewModel
      def show
        return unless current_organization.show_statistics?

        render
      end

      def stats
        @stats ||= HomeStatsPresenter.new(organization: current_organization)
      end
    end
  end
end
