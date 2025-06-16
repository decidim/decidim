# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionStatus
      attr_reader :election

      def initialize(election)
        @election = election
      end

      def current_status
        return :published_results if results_published?
        return :ended if vote_ended? && !results_published?
        return :ongoing if ongoing?
        return :scheduled if scheduled?

        nil
      end

      def localized_status
        I18n.t("decidim.elections.status.#{current_status}")
      end

      def scheduled?
        election.published? && !started? && !vote_ended? && !results_published?
      end

      def started?
        election.start_at.present? && election.start_at <= Time.current
      end

      def ongoing?
        started? && !vote_ended?
      end

      def vote_ended?
        election.end_at.present? && election.end_at <= Time.current
      end

      # Results have been marked as published
      def results_published?
        false # Placeholder for actual logic to determine if results are published
        # election.results_published
      end
    end
  end
end
