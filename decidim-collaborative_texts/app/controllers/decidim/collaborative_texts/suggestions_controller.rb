# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class SuggestionsController < Decidim::CollaborativeTexts::ApplicationController
      include Decidim::FormFactory
      include Decidim::AjaxPermissionHandler

      helper_method :documents, :document

      def index
        render json: suggestions_for(document.consolidated_version)
      end

      def create
        enforce_permission_to :suggest, :collaborative_text
        @form = form(SuggestionForm).from_params(params)

        CreateSuggestion.call(@form) do
          on(:ok) do
            render json: { message: I18n.t("suggestions.create.success", scope: "decidim.collaborative_texts") }
          end

          on(:invalid) do
            message = [I18n.t("suggestions.create.invalid", scope: "decidim.collaborative_texts")]
            message.push(@form.errors.full_messages.join(", ")) if @form.errors.any?
            render json: { message: message.join(" ") }, status: :unprocessable_entity
          end
        end
      end

      private

      def suggestions_for(version)
        version.suggestions.map do |suggestion|
          suggestion.presenter.safe_json.merge(
            profileHtml: cell("decidim/author", suggestion.author.presenter).to_s.strip
          )
        end
      end

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
