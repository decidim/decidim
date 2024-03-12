# frozen_string_literal: true

module Decidim
  module Ai
    class ApplicationJob < Decidim::ApplicationJob
      queue_as :spam_analysis

      protected

      def classifier
        @classifier ||= Decidim::Ai.spam_detection_instance
      end
    end
  end
end
