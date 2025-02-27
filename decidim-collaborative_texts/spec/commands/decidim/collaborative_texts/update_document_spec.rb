# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe UpdateDocument, type: :command do
        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:document) { create(:collaborative_text_document, published_at: nil, title: "This is and original document test title") }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }

        # TODO: check updating a document updates a new document and version with the correct title and body
        # todo: check updating a document ignores :accepting_suggestions and :announcement
        # todo: check traceability (new entry for document and version)
      end
    end
  end
end
