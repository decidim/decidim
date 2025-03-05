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
      include Decidim::Traceable
      include Decidim::Loggable
      include Decidim::Searchable

      component_manifest_name "collaborative_texts"

      after_save :save_version

      has_many :document_versions, class_name: "Decidim::CollaborativeTexts::Version", dependent: :destroy

      validates :title, :body, presence: true

      scope :enabled_desc, -> { order(arel_table[:accepting_suggestions].desc, arel_table[:created_at].desc) }

      searchable_fields(
        participatory_space: { component: :participatory_space },
        A: :title,
        D: :consolidated_body,
        datetime: :published_at
      )
    end
  end
end
