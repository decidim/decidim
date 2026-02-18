# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      class UserSpamAnalyzerJob < GenericSpamAnalyzerJob
        def perform(reportable)
          @author = reportable
          @organization = reportable.organization

          classifier.classify(reportable.about)

          return unless classifier.score >= Decidim::Ai::SpamDetection.user_score_threshold

          Decidim::CreateUserReport.call(form, reportable)
        end

        protected

        def classifier
          @classifier ||= Decidim::Ai::SpamDetection.user_classifier
        end
      end
    end
  end
end
