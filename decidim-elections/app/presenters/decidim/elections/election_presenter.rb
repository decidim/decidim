# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionPresenter < Decidim::ResourcePresenter
      include Decidim::ResourceHelper
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper

      def election
        __getobj__
      end

      def election_path
        return nil unless election

        Decidim::ResourceLocatorPresenter.new(election).path
      end

      def title(html_escape: false, all_locales: false)
        return unless election

        super(election.title, html_escape, all_locales)
      end

      # A JSON representation of the election, including its questions and response options.
      # Suitable for rendering results in real time.
      # Unless `admin: true` is passed, only results for questions with published results are included.
      def to_json(admin: false)
        {
          id: election.id,
          ongoing: election.ongoing?,
          status: election.status,
          start_date: election.start_at&.iso8601,
          end_date: election.end_at.iso8601,
          title: election.translated_attribute(title),
          description: election.translated_attribute(description),
          questions: questions.map do |question|
            {
              id: question.id,
              body: translated_attribute(question.body),
              position: question.position,
              voting_enabled: question.voting_enabled?,
              published_results: question.published_results?,
              response_options: question.response_options.map do |option|
                {
                  id: option.id,
                  body: translated_attribute(option.body)
                }.tap do |hash|
                  next unless admin || result_published_questions.include?(question)

                  hash[:votes_count] = option.votes_count
                  hash[:votes_count_text] = I18n.t("votes_count", scope: "decidim.elections.elections.show", count: option.votes_count)
                  hash[:votes_percent_text] = number_to_percentage(option.votes_percent, precision: 1)
                  hash[:votes_percent] = option.votes_percent
                end
              end
            }
          end
        }
      end
    end
  end
end
