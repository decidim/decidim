# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::StaticPage::TwoPaneSectionCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:static_page) { create(:static_page, organization:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :two_pane_section, scope_name: :static_page, scoped_resource_id: static_page.id, settings:) }
  let(:settings) do
    {
      "left_column_en" => left_content,
      "right_column_en" => right_content
    }
  end

  controller Decidim::PagesController

  context "when both columns contain safe HTML" do
    let(:left_content) { "<p>Left <strong>column</strong></p>" }
    let(:right_content) { "<p>Right <em>column</em></p>" }

    it "renders the allowed HTML tags in both columns" do
      expect(subject).to have_css("strong", text: "column")
      expect(subject).to have_css("em", text: "column")
    end
  end

  context "when the left column contains a script tag" do
    let(:left_content) { '<p>Safe</p><script>alert("left-xss")</script>' }
    let(:right_content) { "<p>Right side</p>" }

    it "strips the script tag from the left column" do
      expect(subject).to have_text("Safe")
      expect(subject.to_s).not_to include("<script>")
    end
  end

  context "when the right column contains an event handler attribute" do
    let(:left_content) { "<p>Left side</p>" }
    let(:right_content) { '<p onmouseover="steal()">Hover</p>' }

    it "strips the event handler from the right column" do
      expect(subject).to have_text("Hover")
      expect(subject.to_s).not_to include("onmouseover")
    end
  end
end
