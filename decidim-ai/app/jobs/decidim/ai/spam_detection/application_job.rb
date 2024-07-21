# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      class ApplicationJob < Decidim::Ai::ApplicationJob
        queue_as :spam_analysis

        protected

        def classifier
          @classifier ||= Decidim::Ai::SpamDetection.resource_classifier
        end
      end
    end
  end
end
