# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # This command is executed when the user creates a Document from the admin
    # panel.
    class Rollout < Decidim::Commands::CreateResource
      fetch_form_attributes :body, :document, :draft

      # 1: add accepter sugestions authors as co-authors
      # 2: transfer non-accepted suggestions to the new version
      def run_after_hooks
        return if form.draft?

        form.pending_suggestions.update!(document_version: resource)
      end

      private

      def resource_class = Decidim::CollaborativeTexts::Version
    end
  end
end
