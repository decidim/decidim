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

      validates :title, presence: true

      scope :enabled_desc, -> { order(arel_table[:accepting_suggestions].desc, arel_table[:created_at].desc) }
      delegate :body, :body=, to: :current_version

      searchable_fields(
        participatory_space: { component: :participatory_space },
        A: :title,
        D: :consolidated_body,
        datetime: :published_at
      )

      def self.log_presenter_class_for(_log)
        Decidim::CollaborativeTexts::AdminLog::DocumentPresenter
      end

      # Returns the current version of the document. Currently, the last one
      def current_version
        document_versions.last || document_versions.build
      end

      def consolidated_version
        document_versions.consolidated.last
      end

      def consolidated_body
        consolidated_version&.body
      end

      # The paranoia gem (used in soft-delete) applies the removed status to the "document_versions" association
      # but it does not recursively restore them by default.
      # This model needs to have the document_versions synchronized always
      def restore
        super(recursive: true)
      end

      private

      def save_version
        current_version.save if current_version.changed?
      end
    end
  end
end
