# frozen_string_literal: true

module Decidim
  module Accountability
    # This class handles statistics of results. Needs a `result` in
    # order to find the stats.
    class ResultStatsCalculator
      # Public: Initializes the service.
      # result - The result from which to calculate the stats.
      def initialize(result)
        @result = result
      end

      delegate :count, to: :proposals, prefix: true

      def votes_count
        return 0 unless proposals

        proposals.sum { |proposal| proposal.votes.size }
      end

      def comments_count
        proposals.sum(:comments_count)
      end

      def attendees_count
        meetings.where("attendees_count > 0").sum(:attendees_count)
      end

      def contributions_count
        meetings.where("contributions_count > 0").sum(:contributions_count)
      end

      delegate :count, to: :meetings, prefix: true

      private

      attr_reader :result

      def proposals
        @proposals ||= result.linked_resources(:proposals, "included_proposals")
      end

      def meetings
        @meetings ||= result.linked_resources(:meetings, "meetings_through_proposals")
      end
    end
  end
end
