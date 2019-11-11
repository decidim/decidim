# frozen_string_literal: true

require "spec_helper"
require "decidim/accountability/test/factories"

describe Decidim::DiffCell, versioning: true, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/diff", model) }
  let(:model) { item.versions.last }

  context "when diffing a translatable attribute that has empty strings" do
    let(:title) { { en: "English title", ca: "Catalan title", es: "" } }
    let(:item) { create(:result, title: title) }

    it "renders an empty diff for the empty attributes" do
      expect(subject).to have_css(".diff-for-title-english .diff-data .ins")
      expect(subject).to have_css(".diff-for-title-catala .diff-data .ins")
      expect(subject).to have_css(".diff-for-title-castellano .diff-data .unchanged")
    end
  end

  context "when diffing an attribute with integer values" do
    let(:item) { create(:proposal, decidim_scope_id: 1) }

    it "renders a diff with a string" do
      expect(subject).to have_css(".diff-for-scope .diff-data .ins")
    end
  end

  describe "view unescaped html" do
    include_context "with content"

    let(:component) { create(:proposal_component, settings: settings) }
    let(:item) { create(:proposal, component: component, body: content) }
    let(:settings) { {} }

    context "when rich text editor is enabled on the frontend" do
      let(:settings) { { rich_editor_public_view: true } }

      it "shows the HTML view dropdown menu" do
        expect(subject).to have_css(".diff-view-html .dropdown .menu")
      end
    end

    context "when rich text editor is NOT enabled on the frontend" do
      let(:settings) { { rich_editor_public_view: false } }

      it "does NOT show the HTML view dropdown menu" do
        expect(subject).not_to have_css(".diff-view-html .dropdown .menu")
      end
    end

    context "with diff_view_unified_unescaped" do
      let(:html) { subject.find(".diff-for-body #diff_view_unified_unescaped") }

      it "renders potentially safe HTML tags unescaped" do
        expect(html).to have_selector("em", text: "em")
        expect(html).to have_selector("u", text: "u")
        expect(html).to have_selector("strong", text: "strong")
      end

      it "sanitizes potentially malicious HTML tags" do
        expect(html).not_to have_selector("script", visible: false)
        expect(html).to have_content("alert('SCRIPT')")
      end
    end

    context "with diff_view_unified_escaped" do
      let(:html) { subject.find(".diff-for-body #diff_view_unified_escaped") }

      it "sanitizes potentially safe HTML tags" do
        expect(html).not_to have_selector("em")
        expect(html).to have_content("em")
        expect(html).not_to have_selector("u")
        expect(html).to have_content("u")
        expect(html).not_to have_selector("strong")
        expect(html).to have_content("strong")
      end

      it "sanitizes potentially malicious HTML tags" do
        expect(html).not_to have_selector("script", visible: false)
        expect(html).to have_content("alert('SCRIPT')")
      end
    end
  end
end
