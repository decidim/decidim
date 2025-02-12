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
      include Decidim::Publicable
      include Decidim::Loggable

      component_manifest_name "collaborative_texts"

      validates :title, presence: true
    end
  end
end
