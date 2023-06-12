# frozen_string_literal: true

require "spec_helper"

describe Decidim::DataConsentCell, type: :cell do
  subject { my_cell.call }

  controller Decidim::ApplicationController

  let(:my_cell) { cell("decidim/data_consent") }

  before do
    allow(Decidim).to receive(:consent_categories).and_return(consent_categories)
  end

  context "when there are consent categories" do
    let(:consent_categories) do
      [
        { slug: "essential", mandatory: true, items: [{ type: "cookie", name: "_session_id" }] }
      ]
    end

    it "renders the cell" do
      expect(subject).to have_css(".dc-categories")
      expect(subject).to have_content "Essential"
      expect(subject).to have_content "These cookies enable key functionality of the website and help to keep its users secured"
      expect(subject).to have_content "_session_id"
    end
  end

  context "when the consent categories do not have irems" do
    let(:consent_categories) do
      [
        { slug: "essential", mandatory: true, items: [{ type: "cookie", name: "_session_id" }] },
        { slug: "preferences", mandatory: false }
      ]
    end

    it "renders the cell with the categories with items" do
      expect(subject).to have_css(".dc-categories")
      expect(subject).to have_content "Essential"
      expect(subject).to have_content "These cookies enable key functionality of the website and help to keep its users secured"
      expect(subject).to have_content "_session_id"

      expect(subject).not_to have_content "Preferences"
    end
  end
end
