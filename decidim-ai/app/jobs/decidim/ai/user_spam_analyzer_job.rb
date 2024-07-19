# frozen_string_literal: true

module Decidim
  module Ai
    class UserSpamAnalyzerJob < GenericSpamAnalyzerJob
      def perform(reportable)
        @author = reportable

        classifier.classify(reportable.about)

        return unless classifier.score >= Decidim::Ai::SpamDetection.user_score_threshold

        Decidim::CreateUserReport.call(form, reportable)
      end
    end
  end
end
