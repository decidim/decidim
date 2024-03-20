# frozen_string_literal: true

module Decidim
  module Consultations
    # This controller provides a widget that allows embedding the question
    class QuestionWidgetsController < Decidim::WidgetsController
      include NeedsQuestion

      helper Decidim::SanitizeHelper

      def show
        enforce_permission_to :embed, :question, question: model if model

        super
      end

      private

      def model
        @model ||= current_question if current_question.published?
      end

      def current_participatory_space
        model
      end

      def iframe_url
        @iframe_url ||= question_question_widget_url(model)
      end

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Consultations::ApplicationController)
      end
    end
  end
end
