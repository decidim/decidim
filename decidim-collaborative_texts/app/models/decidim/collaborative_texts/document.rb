# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # The data store for a document in the Decidim::CollaborativeTexts component. It stores a
    # title, description and any other useful information to render a custom
    # document.
    class Document < CollaborativeTexts::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::SoftDeletable
      include Decidim::HasComponent
      include Decidim::TranslatableAttributes

      component_manifest_name "collaborative_texts"

      validates :title, presence: true

      # Returns the presenter for this collaborative text, to be used in the views.
      # Required by ResourceRenderer.
      def presenter
        Decidim::CollaborativeTexts::CollaborativeTextPresenter.new(self)
      end

      # Public: Checks if the collaborative text has been published or not.
      #
      # Returns Boolean.
      def published?
        published_at.present?
      end

      # Public: Overrides the `reported_content_url` Reportable concern method.
      def reported_content_url
        ResourceLocatorPresenter.new(self).url
      end
    end
  end
end
