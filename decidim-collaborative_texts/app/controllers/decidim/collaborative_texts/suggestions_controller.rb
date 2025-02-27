# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class SuggestionsController < Decidim::CollaborativeTexts::ApplicationController
      helper_method :documents, :document

      def index
        # TODO: sanitize this
        render json: document.current_version.suggestions
      end

      private

      def document
        @document ||= documents.find(params[:document_id])
      end

      def documents
        @documents ||= if current_user&.admin?
                         Document.where(component: current_component)
                       else
                         Document.published.where(component: current_component)
                       end
      end
    end
  end
end
