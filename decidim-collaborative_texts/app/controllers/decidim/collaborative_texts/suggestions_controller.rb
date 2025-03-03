# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class SuggestionsController < Decidim::CollaborativeTexts::ApplicationController
      include Decidim::FormFactory
      helper_method :documents, :document

      def index
        # TODO: sanitize this
        render json: document.current_version.suggestions
      end

      def create
        @form = form(SuggestionForm).from_params(params)

        CreateSuggestion.call(@form) do
          on(:ok) do
            render json: { message: I18n.t("suggestions.create.success", scope: "decidim.collaborative_texts") }
          end

          on(:invalid) do
            render json: { message: I18n.t("suggestions.create.invalid", scope: "decidim.collaborative_texts") }, status: :unprocessable_entity
          end
        end
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
