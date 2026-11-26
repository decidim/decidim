# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # Controller that manages the suggestion votes.
    class SuggestionVotesController < Decidim::CollaborativeTexts::ApplicationController
      include Decidim::AjaxPermissionHandler

      before_action :authenticate_user!

      def create
        enforce_permission_to(:vote, :collaborative_text, document:)

        VoteSuggestion.call(suggestion, current_user, weight: params.expect(:weight).to_i) do
          on(:ok) do
            render json: suggestion.presenter.safe_json(current_user).slice(:upVotesCount, :downVotesCount, :voteWeight)
          end

          on(:invalid) do
            render json: { message: I18n.t("suggestion_votes.create.error", scope: "decidim.collaborative_texts") },
                   status: :unprocessable_content
          end
        end
      end

      private

      def document
        @document ||= Document.published.where(component: current_component).find(params.expect(:document_id))
      end

      def suggestion
        @suggestion ||= document.suggestions.find(params.expect(:suggestion_id))
      end
    end
  end
end
