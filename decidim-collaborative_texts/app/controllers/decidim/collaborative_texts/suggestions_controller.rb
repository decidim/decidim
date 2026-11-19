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
        suggestions = version.suggestions
        vote_counts = vote_counts_for(suggestions)
        user_vote_weights = user_vote_weights_for(suggestions)

        suggestions.map do |suggestion|
          suggestion_json = suggestion.presenter.safe_json(
            current_user,
            vote_counts: vote_counts[suggestion.id] || {},
            user_vote_weight: user_vote_weights.fetch(suggestion.id, 0)
          ).merge(
            profileHtml: cell("decidim/author", suggestion.author.presenter).to_s.strip
          )
          suggestion_json[:votesUrl] = router.document_suggestion_votes_path(document, suggestion) if document.published?
          suggestion_json
        end
      end

      # Fetch the vote totals for all the listed suggestions in a single query.
      def vote_counts_for(suggestions)
        counts = suggestions
                 .joins(:votes)
                 .group(
                   "decidim_collaborative_texts_suggestion_votes.suggestion_id",
                   "decidim_collaborative_texts_suggestion_votes.weight"
                 )
                 .count

        counts.each_with_object({}) do |(key, count), result|
          suggestion_id, weight = key
          result[suggestion_id] ||= {}
          result[suggestion_id][weight] = count
        end
      end

      # Fetch the current participant's votes for all the listed suggestions in a single query.
      def user_vote_weights_for(suggestions)
        return {} unless current_user

        suggestions
          .joins(:votes)
          .where(decidim_collaborative_texts_suggestion_votes: {
                   decidim_author_id: current_user.id,
                   decidim_author_type: current_user.class.base_class.name
                 })
          .pluck(
            "decidim_collaborative_texts_suggestion_votes.suggestion_id",
            "decidim_collaborative_texts_suggestion_votes.weight"
          )
          .to_h
      end

      def document
        @document ||= documents.find(params.expect(:document_id))
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
