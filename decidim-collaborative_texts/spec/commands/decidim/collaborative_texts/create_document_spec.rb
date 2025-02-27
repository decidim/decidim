# frozen_string_literal: true

require "spec_helper"

module Decidim
  module CollaborativeTexts
    module Admin
      describe CreateDocument, type: :command do
        let(:organization) { create(:organization, available_locales: [:en]) }
        let(:document) { create(:collaborative_text_document, published_at: nil, title: "This is and original document test title") }
        let(:current_user) { create(:user, :admin, :confirmed, organization:) }

        # TODO: check creating a document creates a new document and version with the correct title and body
        # todo: check creating a document ignores :accepting_suggestions and :announcement
        # todo: check traceability (new entry for document only and not version)
      end
    end
  end
end
