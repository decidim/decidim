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
end
