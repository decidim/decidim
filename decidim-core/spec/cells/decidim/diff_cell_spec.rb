# frozen_string_literal: true

require "spec_helper"
require "decidim/accountability/test/factories"

describe Decidim::DiffCell, versioning: true, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/diff", model) }
  let(:model) { item.versions.last }
  let(:organization) { item.organization }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(described_class).to receive(:current_organization).and_return(organization)
    allow_any_instance_of(Decidim::BaseDiffRenderer)
      .to receive(:attribute_types).and_return(decidim_scope_id: :scope)
    # rubocop:enable RSpec/AnyInstance
  end

  context "when diffing a translatable attribute that has empty strings" do
    let(:title) { { en: "English title", ca: "Catalan title", es: "" } }
    let(:item) { create(:result, title:) }

    it "renders an empty diff for the empty attributes" do
      expect(subject).to have_css(".diff-for-title-english .diff-data .ins")
      expect(subject).to have_css(".diff-for-title-catala .diff-data .ins")
      expect(subject).to have_css(".diff-for-title-castellano .diff-data .unchanged")
    end
  end

  context "when diffing an attribute with scopes values" do
    let(:item) { create(:dummy_resource) }

    it "renders a diff with a string" do
      expect(subject).to have_css(".diff-for-scope .diff-data .ins", text: item.scope.name[:en])
    end
  end

  describe "view unescaped html" do
    include_context "with rich text editor content"

    let(:item) { create(:proposal, body: { en: content }) }

    context "when rich text editor is enabled on the frontend" do
      before { organization.update(rich_text_editor_in_public_views: true) }

      it "shows the HTML view dropdown menu" do
        expect(subject).to have_css(".diff-view-html .dropdown .menu")
      end
    end

    context "when rich text editor is NOT enabled on the frontend" do
      it "does NOT show the HTML view dropdown menu" do
        expect(subject).not_to have_css(".diff-view-html .dropdown .menu")
      end
    end

    context "with diff_view_unified_unescaped" do
      let(:html) { subject.find(".diff-for-body .diff_view_unified_unescaped") }

      it "renders potentially safe HTML tags unescaped" do
        expect(html).to have_selector("em", text: "em")
        expect(html).to have_selector("u", text: "u")
        expect(html).to have_selector("strong", text: "strong")
      end

      it "sanitizes potentially malicious HTML tags" do
        expect(html).not_to have_selector("script", visible: :all)
        expect(html).to have_content("alert('SCRIPT')")
      end
    end

    context "with diff_view_unified_escaped" do
      let(:html) { subject.find(".diff-for-body .diff_view_unified_escaped") }

      it "sanitizes potentially safe HTML tags" do
        expect(html).not_to have_selector("em")
        expect(html).to have_content("em")
        expect(html).not_to have_selector("u")
        expect(html).to have_content("u")
        expect(html).not_to have_selector("strong")
        expect(html).to have_content("strong")
      end

      it "sanitizes potentially malicious HTML tags" do
        expect(html).not_to have_selector("script", visible: :all)
        expect(html).to have_content("alert('SCRIPT')")
      end
    end

    context "with diff_view_split_unescaped" do
      let(:html) { subject.find(".diff-for-body .diff_view_split_unescaped") }

      it "renders potentially safe HTML tags unescaped" do
        expect(html).to have_selector("em", text: "em")
        expect(html).to have_selector("u", text: "u")
        expect(html).to have_selector("strong", text: "strong")
      end

      it "sanitizes potentially malicious HTML tags" do
        expect(html).not_to have_selector("script", visible: :all)
        expect(html).to have_content("alert('SCRIPT')")
      end
    end

    context "with diff_view_split_escaped" do
      let(:html) { subject.find(".diff-for-body .diff_view_split_escaped") }

      it "sanitizes potentially safe HTML tags" do
        expect(html).not_to have_selector("em")
        expect(html).to have_content("em")
        expect(html).not_to have_selector("u")
        expect(html).to have_content("u")
        expect(html).not_to have_selector("strong")
        expect(html).to have_content("strong")
      end

      it "sanitizes potentially malicious HTML tags" do
        expect(html).not_to have_selector("script", visible: :all)
        expect(html).to have_content("alert('SCRIPT')")
      end
    end
  end
end
