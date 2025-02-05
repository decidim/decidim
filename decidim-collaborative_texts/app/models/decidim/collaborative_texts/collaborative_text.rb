# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # The data store for a CollaborativeText in the Decidim::CollaborativeTexts component. It stores a
    # title, description and any other useful information to render a custom
    # CollaborativeText.
    class CollaborativeText < CollaborativeTexts::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::SoftDeletable
      include Decidim::HasComponent
      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes

      component_manifest_name "collaborative_texts"

      validates :title, presence: true

      # Public: Checks if the collaborative text has been published or not.
      #
      # Returns Boolean.
      def published?
        published_at.present?
      end
    end
  end
end
