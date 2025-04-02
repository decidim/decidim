# frozen_string_literal: true

require "spec_helper"

module Decidim::CollaborativeTexts
  describe DocumentLCell, type: :cell do
    controller Decidim::CollaborativeTexts::DocumentsController

    subject { cell_html }

    let(:my_cell) { cell("decidim/collaborative_texts/document_l", document, context: { show_space: }) }
    let(:cell_html) { my_cell.call }
    let(:created_at) { 1.month.ago }
    let(:published_at) { Time.current }
    let(:component) { create(:collaborative_texts_component) }
    let!(:document) { create(:collaborative_text_document, :with_body, component:, published_at:) }
    let(:model) { document }
    let(:user) { create(:user, organization: document.participatory_space.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it_behaves_like "m-cell", :document

      it "renders the card" do
        expect(subject).to have_css("[id^='collaborative_texts__document_#{document.id}']")
      end

      it "renders the title" do
        expect(subject).to have_content(document.title)
        expect(subject).to have_css(".card__list-title")
      end
    end
  end
end
