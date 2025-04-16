# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # The data store for a document in the Decidim::CollaborativeTexts component. It stores a
    # title, description and any other useful information to render a custom
    # document.
    class Version < CollaborativeTexts::ApplicationRecord
      include Decidim::Resourceable
      include Decidim::SoftDeletable
      include Decidim::Traceable
      include Decidim::Loggable

      belongs_to :document, class_name: "Decidim::CollaborativeTexts::Document"
      validates :body, presence: true
      validates :draft, presence: true, uniqueness: { scope: :document_id }, if: :draft

      default_scope { order(created_at: :asc) }
      scope :consolidated, -> { where(draft: false) }
      scope :draft, -> { where(draft: true) }

      def self.log_presenter_class_for(_log)
        Decidim::CollaborativeTexts::AdminLog::VersionPresenter
      end

      def version_number
        @version_number ||= document.document_versions.where(created_at: ..created_at).count
      end
    end
  end
end
