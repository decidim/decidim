# frozen_string_literal: true

module Decidim
  module Consultations
    # A presenter to render statistics in the homepage.
    class QuestionStatsPresenter < SimpleDelegator
      def question
        __getobj__.fetch(:question)
      end

      def supports_count
        question.votes_count
      end

      def comments_count
        Rails.cache.fetch(
          "question/#{question.id}/comments_count",
          expires_in: Decidim::Consultations.stats_cache_expiration_time
        ) do
          question.comments_count
        end
      end

      def meetings_count
        Rails.cache.fetch(
          "question/#{question.id}/meetings_count",
          expires_in: Decidim::Consultations.stats_cache_expiration_time
        ) do
          Decidim::Meetings::Meeting.where(component: meetings_component).count
        end
      end

      def assistants_count
        Rails.cache.fetch(
          "question/#{question.id}/assistants_count",
          expires_in: Decidim::Consultations.stats_cache_expiration_time
        ) do
          result = 0
          Decidim::Meetings::Meeting.where(component: meetings_component).each do |meeting|
            result += meeting.attendees_count || 0
          end

          result
        end
      end

      private

      def meetings_component
        @meetings_component ||= Decidim::Component.find_by(participatory_space: question, manifest_name: "meetings")
      end
    end
  end
end
