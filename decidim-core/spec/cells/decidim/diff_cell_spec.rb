# frozen_string_literal: true

require "spec_helper"
require "decidim/accountability/test/factories"

describe Decidim::DiffCell, versioning: true, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/diff", model) }
  let(:model) { result.versions.last }
  let(:result) { create(:result, title: title) }

  context "when diffing a translatable attribute that has empty strings" do
    let(:title) do
      {
        en: "English title",
        ca: "Catalan title",
        es: ""
      }
    end

    it "renders an empty diff for the empty attributes" do
      expect(subject).to have_css(".diff-for-title-english .diff-data", text: "English title")
      expect(subject).to have_css(".diff-for-title-catala .diff-data", text: "Catalan title")
      expect(subject).to have_css(".diff-for-title-castellano .diff-data", exact_text: "\n          ")
    end
  end
end
