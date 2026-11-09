# frozen_string_literal: true

require "spec_helper"

module Decidim::CollaborativeTexts
  describe DocumentMetadataCell, type: :cell do
    controller Decidim::CollaborativeTexts::DocumentsController

    subject { cell_html }

    let(:my_cell) { cell("decidim/collaborative_texts/document_metadata", document) }
    let(:cell_html) { my_cell.call }
    let(:document) { create(:collaborative_text_document, :draft) }
    let(:component) { document.component }
    let(:user) { create(:user, :confirmed, organization: component.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it "renders as draft" do
      expect(subject).to have_css("[data-status='draft']", text: "In review")
      expect(subject).to have_css("[data-contributors-count]", text: "1 contributor")
    end

    it "computes the status once per card" do
      expect(document).to receive(:draft?).once.and_call_original
      subject
    end

    context "when the document is accepting suggestions" do
      let(:document) { create(:collaborative_text_document, :published, :accepting_suggestions) }

      it "renders as accepting suggestions" do
        expect(subject).to have_css("[data-status='accepting_suggestions']", text: "Accepting suggestions")
        expect(subject).to have_css("[data-contributors-count]", text: "1 contributor")
      end
    end

    context "when the document is not accepting suggestions" do
      let(:document) { create(:collaborative_text_document, :published, :not_accepting_suggestions) }

      it "renders as not accepting suggestions" do
        expect(subject).to have_css("[data-status='not_accepting_suggestions']", text: "Not accepting suggestions")
        expect(subject).to have_css("[data-contributors-count]", text: "1 contributor")
      end
    end

    context "when the document has suggestions" do
      let(:document) { create(:collaborative_text_document, :published, :accepting_suggestions) }
      let!(:version) { create(:collaborative_text_version, document:, draft: false) }

      before do
        create_list(:collaborative_text_suggestion, 3, document_version: version)
        document.add_coauthor(user)
        document.reload
      end

      it "renders the suggestions count" do
        expect(subject).to have_css("[data-suggestions-count]", text: "3 suggestions")
      end

      it "renders the contributors count" do
        expect(subject).to have_css("[data-contributors-count]", text: "2 contributors")
      end
    end
  end
end
