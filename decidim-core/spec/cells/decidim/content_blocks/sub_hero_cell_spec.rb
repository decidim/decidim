# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::SubHeroCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization, description:) }
  let(:content_block) { create :content_block, organization:, manifest_name: :sub_hero, scope_name: :homepage }

  controller Decidim::PagesController

  context "when description is not filled" do
    let(:description) { {} }

    it "displays nothing" do
      expect(subject).to have_no_css(".subhero")
    end
  end

  context "when description is filled" do
    let(:description) do
      {
        "en" => "<h2><strong>Bold titled text</strong></h2>"
      }
    end

    it "shows the custom welcome text with formating" do
      expect(subject).to have_css(".subhero")
      expect(subject.find("h2 strong")).to have_text("Bold titled text")
    end

    context "with a paragraph of text" do
      let(:description) do
        {
          "en" => "<p><strong>Bold titled text</strong></p>"
        }
      end

      it "shows the custom welcome text with formating" do
        expect(
          subject.find(".heading2").native.inner_html.strip
        ).to eq("<strong>Bold titled text</strong>")
      end
    end

    context "with two paragraphs of text" do
      let(:description) do
        {
          "en" => <<~HTML
            <p><strong>First row of text</strong></p>
            <p>Second row of text</p>
          HTML
        }
      end

      it "shows the custom welcome text with formating" do
        expect(
          subject.find(".heading2").native.inner_html.strip
        ).to include(
          "<strong>First row of text</strong><br><br>Second row of text"
        )
      end
    end
  end
end
