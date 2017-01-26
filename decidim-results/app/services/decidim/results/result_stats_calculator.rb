# frozen_string_literal: true
module Decidim
  module Results
    # This class handles statistics of results. Needs a `result` in
    # order to find the stats.
    class ResultStatsCalculator
      # Public: Initializes the service.
      # result - The result from which to calculate the stats.
      def initialize(result)
        @result = result
      end

      def proposals_count
        proposals.count
      end

      def votes_count
        return 0 unless proposals
        proposals.sum{ |proposal| proposal.votes.size }
      end

      def comments_count
        Decidim::Comments::Comment.where(commentable: proposals).count
      end

      def attendees_count
        meetings.where("attendees_count > 0").sum(:attendees_count)
      end

      def contributions_count
        meetings.where("contributions_count > 0").sum(:contributions_count)
      end

      def meetings_count
        meetings.count
      end

      private

      attr_reader :result

      def proposals
        @proposals ||= result.linked_resources(:proposals, "proposals_from_result")
      end

      def meetings
        @meetings ||= result.linked_resources(:meetings, "meetings_from_result")
      end
    end
  end
end
