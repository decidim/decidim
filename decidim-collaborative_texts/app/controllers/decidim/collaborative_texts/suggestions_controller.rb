# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    class SuggestionsController < Decidim::CollaborativeTexts::ApplicationController
      include Decidim::FormFactory
      include Decidim::AjaxPermissionHandler

      helper_method :documents, :document

      def index
        enforce_permission_to(:read, :collaborative_text, document:)

        render json: suggestions_for(document.consolidated_version)
      end

      def show
        enforce_permission_to(:read, :collaborative_text, document:)

        query = { suggestionId: suggestion.id, commentId: params[:commentId] }.compact
        redirect_to Decidim::ResourceLocatorPresenter.new(document).path(query)
      end

      def comments
        enforce_permission_to(:read, :collaborative_text, document:)

        render html: cell("decidim/comments/comments", suggestion, hide_comments_header: true).to_s
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
            render json: { message: message.join(" ") }, status: :unprocessable_content
          end
        end
      end

      private

      def suggestions_for(version)
        router = Decidim::EngineRouter.main_proxy(current_component)

        version.suggestions.includes(author: [:organization, { avatar_attachment: :blob }]).map do |suggestion|
          suggestion.presenter.safe_json.merge(
            profileHtml: cell("decidim/author", suggestion.author.presenter).to_s.strip,
            commentableGid: suggestion.to_signed_global_id.to_s,
            commentsUrl: router.comments_suggestion_path(suggestion)
          )
        end
      end

      def suggestion
        @suggestion ||= document.suggestions.find(params.expect(:id))
      end

      def document
        @document ||= if params[:document_id]
                        documents.find(params.expect(:document_id))
                      else
                        documents.joins(document_versions: :suggestions).find_by!(decidim_collaborative_texts_suggestions: { id: params.expect(:id) })
                      end
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
