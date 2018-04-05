# frozen_string_literal: true

module Decidim
  module Consultations
    # This controller provides a widget that allows embedding the question
    class QuestionWidgetsController < Decidim::WidgetsController
      include NeedsQuestion

      helper Decidim::SanitizeHelper

      private

      def model
        @model ||= current_question
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= question_question_widget_url(model)
      end
    end
  end
end
