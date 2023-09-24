# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class ParticipatorySpaceStatsCell < BaseCell
      def show
        return if stats.blank?

        render
      end

      private

      def stats; end

      def data
        { statistics: "" }
      end
    end
  end
end
