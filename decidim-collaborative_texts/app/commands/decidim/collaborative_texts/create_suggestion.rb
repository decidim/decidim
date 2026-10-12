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
      # suggestion creation and rollout cannot deadlock on the counter updates.
      def run_before_hooks
        Decidim::CollaborativeTexts::Document.lock.find(form.document.id)
        version = form.document_version
        Decidim::CollaborativeTexts::Version.lock.find(version.id) if version.persisted?
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
