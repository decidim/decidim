# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # This command is executed when the user creates a Document from the admin
    # panel.
    class CreateSuggestion < Decidim::Commands::CreateResource
      fetch_form_attributes :author, :document_version, :changeset

      private

      def resource_class = Decidim::CollaborativeTexts::Suggestion

      # Lock the rows in the same order as Rollout (document first, then version) so concurrent
      # suggestion creation and rollout cannot deadlock on the counter updates. Both locks go
      # through the tenant instead of a bare ID. A document has no organization column - its
      # organization comes from the component through a polymorphic participatory space, which
      # cannot be joined - so the component the user is acting in is the anchor, and the version is
      # locked through the document that owns it. A record from another organization is never
      # locked or written to.
      def run_before_hooks
        document = form.document
        version = form.document_version

        Decidim::CollaborativeTexts::Document.where(component: form.current_component).lock.find(document.id)
        document.document_versions.lock.find(version.id) if version.persisted?
      end

      def extra_params
        {
          extra: {
            participatory_space: {
              title: form.document&.participatory_space&.title
            },
            resource: {
              title: form.document&.title
            }
          }
        }
      end
    end
  end
end
