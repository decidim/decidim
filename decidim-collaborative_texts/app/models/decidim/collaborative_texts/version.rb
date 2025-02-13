# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # The data store for a document in the Decidim::CollaborativeTexts component. It stores a
    # title, description and any other useful information to render a custom
    # document.
    class Version < CollaborativeTexts::ApplicationRecord
      belongs_to :document, class_name: "Decidim::CollaborativeTexts::Document"
      validates :body, presence: true

      default_scope { order(created_at: :desc) }
    end
  end
end
