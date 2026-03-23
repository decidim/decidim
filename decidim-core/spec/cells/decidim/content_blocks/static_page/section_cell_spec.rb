# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlocks::StaticPage::SectionCell, type: :cell do
  subject { cell(content_block.cell, content_block).call }

  let(:organization) { create(:organization) }
  let(:static_page) { create(:static_page, organization:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :section, scope_name: :static_page, scoped_resource_id: static_page.id, settings:) }
  let(:settings) do
    {
      "content_en" => html_content
    }
  end

  controller Decidim::PagesController

  context "when the content contains safe HTML" do
    let(:html_content) { "<p>Section <em>content</em></p>" }

    it "renders the allowed HTML tags" do
      expect(subject).to have_css("p")
      expect(subject).to have_css("em", text: "content")
    end
  end

  context "when the content contains a script tag" do
    let(:html_content) { '<p>Safe</p><script>alert("xss")</script>' }

    it "strips the script tag" do
      expect(subject).to have_text("Safe")
      expect(subject.to_s).not_to include("<script>")
    end
  end

  context "when the content contains an event handler attribute" do
    let(:html_content) { '<div onclick="steal()">Click</div>' }

    it "strips the event handler" do
      expect(subject).to have_text("Click")
      expect(subject.to_s).not_to include("onclick")
    end
  end
end
