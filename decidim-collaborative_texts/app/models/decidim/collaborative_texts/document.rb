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

      after_save :save_version

      has_many :document_versions, class_name: "Decidim::CollaborativeTexts::Version", dependent: :destroy

      validates :title, :body, presence: true

      scope :enabled_desc, -> { order(arel_table[:accepting_suggestions].desc, arel_table[:created_at].desc) }

      delegate :body, :body=, to: :current_version

      # Returns the current version of the document. Currently, the last one.
      def current_version
        document_versions.last || document_versions.build
      end

      # Creates a new version of the document
      def rollout!
        document_versions.build(body: body)
      end

      private

      def save_version
        current_version.save
      end
    end
  end
end
