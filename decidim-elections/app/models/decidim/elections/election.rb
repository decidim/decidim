# frozen_string_literal: true

module Decidim
  module Elections
    # The data store for a document in the Decidim::Elections component. It stores a
    # title, description and any other useful information to render a custom
    # document.
    class Election < Elections::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::SoftDeletable
      include Decidim::HasComponent
      include Decidim::Publicable
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Searchable

      component_manifest_name "elections"
    end
  end
end
