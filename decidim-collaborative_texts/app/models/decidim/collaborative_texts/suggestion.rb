# frozen_string_literal: true

module Decidim
  module CollaborativeTexts
    # The data store for a document in the Decidim::CollaborativeTexts component. It stores a
    # title, description and any other useful information to render a custom
    # document.
    class Suggestion < CollaborativeTexts::ApplicationRecord
      include Decidim::Traceable
      include Decidim::Authorable
      include Decidim::ApplicationHelper

      enum status: [:pending, :accepted, :rejected]
      belongs_to :document_version, class_name: "Decidim::CollaborativeTexts::Version"
      has_one :document, class_name: "Decidim::CollaborativeTexts::Document", through: :document_version

      delegate :organization, to: :document

      # A summary to print in the UI. Without HTML.
      # todo: add type: edit, removal, addition
      def summary
        @summary ||= ActionView::Base.full_sanitizer.sanitize(changeset["replace"]&.join(", ")&.strip).truncate(150)
      end
    end
  end
end
