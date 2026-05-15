# frozen_string_literal: true

require "spec_helper"

describe Decidim::CollaborativeTexts::DocumentCell, type: :cell do
  controller Decidim::CollaborativeTexts::DocumentsController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/collaborative_texts/document", model) }
  let!(:user_document) { create(:collaborative_text_document) }
  let!(:current_user) { create(:user, :confirmed, organization: model.participatory_space.organization) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when rendering a user collaborative text document" do
    let(:model) { user_document }

    it "renders the card" do
      expect(subject).to have_css("#collaborative_texts__document_#{user_document.id}")
    end
  end
end
