# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # The data store for a CollaborativeText in the Decidim::CollaborativeTexts component. It stores a
    # title, description and any other useful information to render a custom
    # CollaborativeText.
    class CollaborativeText < CollaborativeTexts::ApplicationRecord
    end
  end
end
