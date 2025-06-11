# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionStatus
      attr_reader :election

      def initialize(election)
        @election = election
      end

      def current_status
        case
        when scheduled?
          :scheduled
        when ongoing?
          :ongoing
        when finished? && !results_published?
          :ended
        when results_published?
          :published_results
        end
      end

      def localized_status
        I18n.t("decidim.elections.status.#{current_status}")
      end

      def scheduled?
        election.published? && !started? && !vote_ended?
      end

      def started?
        return false if election.start_at.nil?

        election.start_at < Time.current
      end

      def ongoing?
        started? && !vote_ended?
      end

      def vote_ended?
        election.end_at.present? && election.end_at < Time.current
      end

      def finished?
        return true if vote_ended?
        return true if results_published?

        election.end_at < Time.current
      end

      # TODO: This method should be implemented in the future
      def results_published?
        false
      end
    end
  end
end
