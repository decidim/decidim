# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # This command is executed when the user creates a Document from the admin
    # panel.
    class Rollout < Decidim::Commands::CreateResource
      fetch_form_attributes :body, :document, :draft

      # 1: add accepted suggestions authors as co-authors
      # 2: transfer non-accepted suggestions to the new version
      def run_after_hooks
        process_accepted_suggestions
        return if form.draft?

        move_pending_suggestions
      end

      private

      def resource_class = Decidim::CollaborativeTexts::Version

      # move pending suggestions to the new version
      # rubocop:disable Rails/SkipsModelValidations
      def move_pending_suggestions
        return if form.pending_suggestions.empty?

        form.pending_suggestions.update_all(document_version_id: resource.id)
      end
      # rubocop:enable Rails/SkipsModelValidations

      # Add as co-authors and change the status of the suggestions to accepted
      def process_accepted_suggestions
        affected_users = []
        form.accepted_suggestions.each do |suggestion|
          suggestion.accepted!
          resource.document.add_coauthor suggestion.author
          affected_users << suggestion.author
        end

        Decidim::EventsManager.publish(
          event: "decidim.events.collaborative_texts.suggestion_accepted",
          event_class: Decidim::CollaborativeTexts::SuggestionAcceptedEvent,
          resource: resource.document,
          affected_users: affected_users.uniq
        )
      end
    end
  end
end
