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

        document = resource.document

        # Lock the rows in the same order as CreateSuggestion (document first, then versions) so
        # concurrent suggestion creation and rollout cannot deadlock on the counter updates. Both
        # locks go through the tenant instead of a bare ID: the document is anchored to the component
        # the user is acting in, since a document has no organization column and its organization is
        # only reachable through a polymorphic participatory space that cannot be joined, and the
        # versions are locked through the document that owns them.
        Decidim::CollaborativeTexts::Document.where(component: form.current_component).lock.find(document.id)
        document.document_versions.lock.find(source_version_ids)

        form.pending_suggestions.update_all(document_version_id: resource.id)

        # update_all skips the counter cache callbacks, so recalculate the counters of the affected versions
        Decidim::CollaborativeTexts::Version.reset_counters([resource.id] + source_version_ids, :suggestions)
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
