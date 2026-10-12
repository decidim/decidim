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
      # rubocop:disable-next Rails/SkipsModelValidations
      def move_pending_suggestions
        return if form.pending_suggestions.empty?

        source_version_ids = form.pending_suggestions.pluck(:document_version_id).uniq.sort

        # Lock the rows in the same order as CreateSuggestion (document first, then versions) so
        # concurrent suggestion creation and rollout cannot deadlock on the counter updates.
        Decidim::CollaborativeTexts::Document.lock.find(resource.document.id)
        source_version_ids.each { |version_id| Decidim::CollaborativeTexts::Version.lock.find(version_id) }

        form.pending_suggestions.update_all(document_version_id: resource.id)

        # update_all skips the counter cache callbacks, so recalculate the counters of the affected versions
        ([resource.id] + source_version_ids).each do |version_id|
          Decidim::CollaborativeTexts::Version.reset_counters(version_id, :suggestions)
        end
      end

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
