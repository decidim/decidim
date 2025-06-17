# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionStatus
      attr_reader :election

      def initialize(election)
        @election = election
      end

      def current_status
        return :results_published if results_published?
        return :ended if vote_ended?
        return :ongoing if ongoing?

        :scheduled
      end

      def localized_status
        I18n.t("decidim.elections.status.#{current_status}")
      end

      def scheduled?
        election.published? && !ongoing? && !vote_ended? && !results_published?
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

      def ready_to_publish_results?
        vote_ended? && !results_published?
      end

      def results_published?
        case election.results_availability
        when "real_time"
          vote_ended?
        when "per_question"
          election.questions.all?(&:published_results_at)
        when "after_end"
          election.published_results_at.present?
        else
          false
        end
      end
    end
  end
end
