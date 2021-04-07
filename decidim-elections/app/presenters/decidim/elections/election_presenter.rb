# frozen_string_literal: true

module Decidim
  module Elections
    #
    # Decorator for election
    #
    class ElectionPresenter < SimpleDelegator
      include Decidim::SanitizeHelper
      include Decidim::TranslatableAttributes

      def election
        __getobj__
      end

      def title
        content = translated_attribute(election.title)
        decidim_html_escape(content)
      end

      def description(strip_tags: false)
        content = translated_attribute(election.description)
        content = strip_tags(content) if strip_tags
        content
      end

      def answers_count
        @answers_count ||= election.questions.sum { |q| q.answers.count }
      end

      def questions_count
        @questions_count ||= election.questions.count
      end

      def total_votes
        @total_votes ||= election.results.total_election.sum(&:votes_count)
      end

      def total_valid_votes
        @total_valid_votes ||= election.results.valid_answer.sum(&:votes_count) / answers_count
      end

      def total_blank_votes
        @total_blank_votes ||= (election.results.blank_question.sum(&:votes_count) / questions_count).round
      end

      def total_null_votes
        @total_null_votes ||= election.results.null_ballot.sum(&:votes_count)
      end

      def total_votes_percentage
        @total_votes_percentage ||= percentage_of(total_votes)
      end

      def total_valid_votes_percentage
        @total_valid_votes_percentage ||= percentage_of(total_valid_votes)
      end

      def total_blank_votes_percentage
        @total_blank_votes_percentage ||= percentage_of(total_blank_votes)
      end

      def total_null_votes_percentage
        @total_null_votes_percentage ||= percentage_of(total_null_votes)
      end

      def percentage_of(num)
        return 0 unless num.positive?

        result = num.to_f / total_votes * 100.0
        result.floor(1)
      end
    end
  end
end
