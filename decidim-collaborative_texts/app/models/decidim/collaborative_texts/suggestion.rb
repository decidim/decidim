# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # The data store for a document in the Decidim::CollaborativeTexts component. It stores a
    # title, description and any other useful information to render a custom
    # document.
    class Suggestion < CollaborativeTexts::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Authorable

      enum status: [:pending, :accepted, :rejected]
      belongs_to :document_version, class_name: "Decidim::CollaborativeTexts::Version"
      has_one :document, class_name: "Decidim::CollaborativeTexts::Document", through: :document_version

      delegate :organization, to: :document

      def presenter
        @presenter ||= Decidim::CollaborativeTexts::SuggestionPresenter.new(self)
      end
    end
  end
end
